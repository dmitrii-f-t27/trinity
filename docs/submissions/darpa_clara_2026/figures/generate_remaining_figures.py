#!/usr/bin/env python3
"""
DARPA CLARA Proposal — Remaining Figures Generator

Generates Figures 4, 5, 6, 8:
- F4: FPGA Resource Utilization
- F5: VSA Operations Visualization
- F6: Project Timeline (Gantt Chart)
- F8: Risk Reduction Comparison

Usage:
    python generate_remaining_figures.py

Output:
    figures/fig4_fpga_resources.pdf
    figures/fig5_vsa_operations.pdf
    figures/fig6_timeline_gantt.pdf
    figures/fig8_risk_reduction.pdf
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, Rectangle, FancyArrowPatch
import numpy as np
from datetime import datetime, timedelta

def create_fpga_resources_figure():
    """
    Create Figure 4: FPGA Resource Utilization comparison.
    """
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    # Data
    systems = ['Standard\nGPU', 'Standard\nFPGA', 'Trinity\nZero-DSP']
    lut_data = [None, 65, 19.6]  # % - GPU doesn't use LUT
    dsp_data = [100, 45, 0]      # %
    power_data = [12.0, 8.5, 1.2]  # W

    colors = ['#9CA3AF', '#F59E0B', '#2563EB']

    # Panel 1: LUT Utilization
    ax1 = axes[0]
    x_pos = [1, 2]
    bars1 = ax1.bar(x_pos, [lut_data[1], lut_data[2]],
                    color=[colors[1], colors[2]], alpha=0.8,
                    edgecolor='black', linewidth=1.5)
    ax1.set_ylabel('LUT Utilization (%)', fontsize=11, fontweight='bold')
    ax1.set_title('LUT Utilization', fontsize=12, fontweight='bold')
    ax1.set_xticks(x_pos)
    ax1.set_xticklabels(['Standard\nFPGA', 'Trinity\nZero-DSP'])
    ax1.set_ylim(0, 80)

    # Add value labels
    for i, (bar, val) in enumerate(zip(bars1, [lut_data[1], lut_data[2]])):
        ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 2,
                f'{val}%', ha='center', fontsize=11, fontweight='bold')

    # Panel 2: DSP Usage
    ax2 = axes[1]
    x_pos = [0, 1, 2]
    bars2 = ax2.bar(x_pos, dsp_data, color=colors, alpha=0.8,
                    edgecolor='black', linewidth=1.5)
    ax2.set_ylabel('DSP Usage (%)', fontsize=11, fontweight='bold')
    ax2.set_title('DSP Usage (Trinity = 0)', fontsize=12, fontweight='bold')
    ax2.set_xticks(x_pos)
    ax2.set_xticklabels(systems)
    ax2.set_ylim(0, 120)

    # Add value labels and highlight Trinity
    for i, (bar, val) in enumerate(zip(bars2, dsp_data)):
        color = '#10B981' if val == 0 else 'black'
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 5,
                f'{val}%', ha='center', fontsize=11, fontweight='bold', color=color)

    # Panel 3: Power Consumption
    ax3 = axes[2]
    x_pos = [0, 1, 2]
    bars3 = ax3.bar(x_pos, power_data, color=colors, alpha=0.8,
                    edgecolor='black', linewidth=1.5)
    ax3.set_ylabel('Power (W)', fontsize=11, fontweight='bold')
    ax3.set_title('Power Consumption', fontsize=12, fontweight='bold')
    ax3.set_xticks(x_pos)
    ax3.set_xticklabels(systems)
    ax3.set_ylim(0, 15)

    # Add value labels and efficiency annotation
    for i, (bar, val) in enumerate(zip(bars3, power_data)):
        ax3.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
                f'{val}W', ha='center', fontsize=11, fontweight='bold')

    # Efficiency annotation
    efficiency = power_data[0] / power_data[2]
    ax3.annotate(f'10×\nefficiency',
                xy=(2, 1.2), xytext=(1, 10),
                arrowprops=dict(arrowstyle='->', color='#10B981', lw=2.5),
                fontsize=11, fontweight='bold', color='#10B981',
                ha='center', bbox=dict(boxstyle='round,pad=0.3',
                                       facecolor='#D1FAE5', edgecolor='#10B981'))

    fig.suptitle('Figure 4: FPGA Resource Utilization Comparison',
                fontsize=14, fontweight='bold', y=1.02)

    return fig


def create_vsa_operations_figure():
    """
    Create Figure 5: VSA Operations visualization.
    """
    fig, ax = plt.subplots(figsize=(12, 8))

    # Define colors
    color_value = '#2563EB'
    color_bound = '#10B981'
    color_bundle = '#F59E0B'
    color_arrow = '#374151'

    # Operation 1: BIND
    y_start = 6.5
    rounded_box(ax, 0.5, y_start, 2, 0.6, color_value, 'Value A', fontsize=11)
    rounded_box(ax, 3.5, y_start, 2, 0.6, color_value, 'Value B', fontsize=11)
    draw_arrow(ax, 2.5, y_start + 0.3, 3, y_start - 0.8)
    draw_arrow(ax, 4.5, y_start + 0.3, 3, y_start - 0.8)
    rounded_box(ax, 2, y_start - 1.2, 2, 0.6, color_bound, 'BIND → Bound Vector', fontsize=11)
    ax.text(6, y_start - 0.9, 'O(1) associative memory',
            fontsize=10, style='italic', color='#6B7280')

    # Operation 2: UNBIND
    y_start = 4.5
    rounded_box(ax, 0.5, y_start, 2, 0.6, color_bound, 'Bound Vector', fontsize=11)
    rounded_box(ax, 3.5, y_start, 2, 0.6, color_value, 'Key (B)', fontsize=11)
    draw_arrow(ax, 2.5, y_start + 0.3, 3, y_start - 0.8)
    draw_arrow(ax, 4.5, y_start + 0.3, 3, y_start - 0.8)
    rounded_box(ax, 2, y_start - 1.2, 2, 0.6, color_value, 'UNBIND → Retrieved A', fontsize=11)
    ax.text(6, y_start - 0.9, 'bind(bind(a,b),b) = a',
            fontsize=10, style='italic', color='#6B7280')

    # Operation 3: BUNDLE2
    y_start = 2.5
    rounded_box(ax, 0.5, y_start, 2, 0.6, color_value, 'Value A', fontsize=11)
    rounded_box(ax, 3.5, y_start, 2, 0.6, color_value, 'Value B', fontsize=11)
    draw_arrow(ax, 2.5, y_start + 0.3, 3, y_start - 0.8)
    draw_arrow(ax, 4.5, y_start + 0.3, 3, y_start - 0.8)
    rounded_box(ax, 2, y_start - 1.2, 2, 0.6, color_bundle, 'BUNDLE2 → Majority Vote', fontsize=11)
    ax.text(6, y_start - 0.9, 'O(1) for 2 vectors',
            fontsize=10, style='italic', color='#6B7280')

    # Operation 4: BUNDLE3
    y_start = 0.5
    rounded_box(ax, 0, y_start, 1.2, 0.6, color_value, 'A', fontsize=11)
    rounded_box(ax, 1.8, y_start, 1.2, 0.6, color_value, 'B', fontsize=11)
    rounded_box(ax, 3.6, y_start, 1.2, 0.6, color_value, 'C', fontsize=11)
    draw_arrow(ax, 0.6, y_start + 0.3, 2.5, y_start - 0.8)
    draw_arrow(ax, 2.4, y_start + 0.3, 2.5, y_start - 0.8)
    draw_arrow(ax, 4.2, y_start + 0.3, 2.5, y_start - 0.8)
    rounded_box(ax, 1.8, y_start - 1.2, 2, 0.6, color_bundle, 'BUNDLE3 → 3-Way Vote', fontsize=11)
    ax.text(6, y_start - 0.9, 'O(1) for 3 vectors',
            fontsize=10, style='italic', color='#6B7280')

    # Cosine similarity annotation
    ax.text(9, 5, 'Properties:', fontsize=12, fontweight='bold')
    ax.text(9, 4.3, '• Self-inverting: bind(bind(a,b),b) = a',
            fontsize=10)
    ax.text(9, 3.7, '• Cosine similarity: [-1, 1] range',
            fontsize=10)
    ax.text(9, 3.1, '• Bitflip resilience: 30% (vs 20% HRR)',
            fontsize=10)
    ax.text(9, 2.5, '• FHRR: Frequency Holographic',
            fontsize=10)
    ax.text(9, 1.9, '  Reduced Representation',
            fontsize=10, style='italic')

    # Styling
    ax.set_xlim(0, 12)
    ax.set_ylim(-0.5, 7.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Title
    ax.text(5.5, 7.5, "Figure 5: Vector Symbolic Architecture (VSA) Operations",
            ha='center', va='center',
            fontsize=14, fontweight='bold',
            color='#1F2937')

    return fig


def create_timeline_gantt_figure():
    """
    Create Figure 6: Project Timeline (Gantt Chart).
    """
    fig, ax = plt.subplots(figsize=(14, 6))

    # Phase data
    phases = [
        {'name': 'Phase 1: Foundation', 'start': 0, 'duration': 6,
         'color': '#2563EB', 'milestones': ['M1', 'M2', 'M3', 'M3.5']},
        {'name': 'Phase 2: High-Assurance ML', 'start': 6, 'duration': 6,
         'color': '#10B981', 'milestones': ['M4', 'M5', 'M6']},
        {'name': 'Phase 3: Compositional', 'start': 12, 'duration': 6,
         'color': '#F59E0B', 'milestones': ['M7', 'M8', 'M9']},
        {'name': 'Phase 4: Transition', 'start': 18, 'duration': 6,
         'color': '#8B5CF6', 'milestones': ['M10', 'M11', 'M12']},
    ]

    # Draw Gantt bars
    y_positions = np.arange(len(phases))
    for i, phase in enumerate(phases):
        y = len(phases) - i - 1

        # Phase bar
        ax.barh(y, phase['duration'], left=phase['start'],
               height=0.5, color=phase['color'], alpha=0.8,
               edgecolor='black', linewidth=1.5)

        # Phase label
        ax.text(phase['start'] + phase['duration']/2, y + 0.35,
               phase['name'], ha='center', va='bottom',
               fontsize=10, fontweight='bold')

        # Month labels
        for month in range(phase['start'], phase['start'] + phase['duration']):
            ax.text(month + 0.5, y, f'M{month+1}',
                   ha='center', va='center',
                   fontsize=7, color='white')

        # Milestone markers
        for j, ms in enumerate(phase['milestones']):
            ms_x = phase['start'] + (j + 1) * phase['duration'] / (len(phase['milestones']) + 1)
            ax.plot(ms_x, y + 0.25, 'D', color='white',
                   markersize=6, markeredgecolor='black', markeredgewidth=1)
            ax.text(ms_x, y - 0.3, ms,
                   ha='center', va='top', fontsize=7, fontweight='bold')

    # Styling
    ax.set_xlabel('Project Month', fontsize=11, fontweight='bold')
    ax.set_yticks(y_positions)
    ax.set_yticklabels([phase['name'] for phase in reversed(phases)])
    ax.set_xlim(0, 24)
    ax.set_ylim(-0.5, len(phases) - 0.5)
    ax.grid(axis='x', alpha=0.3)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    # Milestone legend
    ax.text(24.5, 3, 'Milestones:', fontsize=10, fontweight='bold')
    ax.text(24.5, 2.5, 'M3.5: Calibration', fontsize=8)
    ax.text(24.5, 2.2, 'Infrastructure (Month 7)', fontsize=8, style='italic')
    ax.text(24.5, 1.5, 'All bundles ECE < 0.12', fontsize=8)
    ax.text(24.5, 1.2, 'NeurIPS 2025 compliant', fontsize=8, style='italic')

    # Title
    ax.text(12, 4.2, "Figure 6: Trinity S³AI 24-Month Project Timeline",
            ha='center', va='center',
            fontsize=13, fontweight='bold',
            color='#1F2937')

    return fig


def create_risk_reduction_figure():
    """
    Create Figure 8: Risk Reduction Before/After Calibration.
    """
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Risk data
    risks = [
        'Uncertainty\nwithout safety',
        'Overconfident\npredictions',
        'Unreliable\ndecision\nthresholds',
    ]

    before_levels = ['HIGH', 'HIGH', 'MEDIUM']
    after_levels = ['LOW', 'LOW', 'LOW']
    reductions = [67, 67, 33]

    # Color mapping for risk levels
    risk_colors = {'HIGH': '#EF4444', 'MEDIUM': '#F59E0B', 'LOW': '#10B981'}

    # Panel 1: Before Calibration
    ax1 = axes[0]
    y_pos = np.arange(len(risks))
    for i, (risk, level) in enumerate(zip(risks, before_levels)):
        ax1.barh(i, 1, color=risk_colors[level], alpha=0.8,
                edgecolor='black', linewidth=1.5)
        ax1.text(0.5, i, level, ha='center', va='center',
                fontsize=12, fontweight='bold', color='white')

    ax1.set_yticks(y_pos)
    ax1.set_yticklabels(risks)
    ax1.set_xlabel('Risk Level', fontsize=11, fontweight='bold')
    ax1.set_title('Before Calibration', fontsize=12, fontweight='bold')
    ax1.set_xlim(0, 1)
    ax1.spines['top'].set_visible(False)
    ax1.spines['right'].set_visible(False)
    ax1.spines['bottom'].set_visible(False)
    ax1.set_xticks([])

    # Panel 2: After Calibration
    ax2 = axes[1]
    for i, (risk, level, reduction) in enumerate(zip(risks, after_levels, reductions)):
        ax2.barh(i, 1, color=risk_colors[level], alpha=0.8,
                edgecolor='black', linewidth=1.5)
        ax2.text(0.5, i, level, ha='center', va='center',
                fontsize=12, fontweight='bold', color='white')

        # Reduction annotation
        ax2.text(1.1, i, f'-{reduction}%', ha='left', va='center',
                fontsize=11, fontweight='bold', color='#10B981')

        # Arrow from before to after
        if i == 0:
            arrow = FancyArrowPatch((1.2, i), (0.3, i),
                                   arrowstyle='->', mutation_scale=20,
                                   color='#10B981', linewidth=2,
                                   connectionstyle="arc3,rad=.3")
            axes[0].add_patch(arrow)

    ax2.set_yticks(y_pos)
    ax2.set_yticklabels(risks)
    ax2.set_xlabel('Risk Level', fontsize=11, fontweight='bold')
    ax2.set_title('After Calibration', fontsize=12, fontweight='bold')
    ax2.set_xlim(0, 1.5)
    ax2.spines['top'].set_visible(False)
    ax2.spines['right'].set_visible(False)
    ax2.spines['bottom'].set_visible(False)
    ax2.set_xticks([])

    # Legend
    legend_elements = [
        plt.Rectangle((0, 0), 1, 1, facecolor=risk_colors['HIGH'],
                     edgecolor='black', label='HIGH Risk'),
        plt.Rectangle((0, 0), 1, 1, facecolor=risk_colors['MEDIUM'],
                     edgecolor='black', label='MEDIUM Risk'),
        plt.Rectangle((0, 0), 1, 1, facecolor=risk_colors['LOW'],
                     edgecolor='black', label='LOW Risk'),
    ]
    fig.legend(handles=legend_elements, loc='upper center',
              bbox_to_anchor=(0.5, 0.92), ncol=3, fontsize=9)

    fig.suptitle('Figure 8: Risk Reduction from Calibration Metrics',
                fontsize=14, fontweight='bold', y=0.98)

    return fig


# Helper functions
def rounded_box(ax, x, y, width, height, color, text, text_color="white", fontsize=9):
    """Draw a rounded box with text."""
    box = FancyBboxPatch((x, y), width, height,
                          boxstyle="round,pad=0.05",
                          facecolor=color, edgecolor='black',
                          linewidth=1.5, alpha=0.9)
    ax.add_patch(box)
    ax.text(x + width/2, y + height/2, text,
            ha='center', va='center',
            color=text_color, fontsize=fontsize,
            fontweight='bold')

def draw_arrow(ax, x1, y1, x2, y2):
    """Draw an arrow between two points."""
    arrow = FancyArrowPatch((x1, y1), (x2, y2),
                            arrowstyle='->',
                            mutation_scale=15,
                            color='#374151',
                            linewidth=2)
    ax.add_patch(arrow)


def main():
    """
    Generate all remaining figures.
    """
    import os

    # Create output directory
    output_dir = "figures"
    os.makedirs(output_dir, exist_ok=True)

    print("Generating remaining figures...")

    # Generate FPGA resources figure
    print("  - Figure 4: FPGA Resource Utilization")
    fig4 = create_fpga_resources_figure()
    fig4.savefig(f"{output_dir}/fig4_fpga_resources.pdf",
                 dpi=300, bbox_inches='tight', format='pdf')
    fig4.savefig(f"{output_dir}/fig4_fpga_resources.png",
                 dpi=300, bbox_inches='tight', format='png')
    plt.close(fig4)

    # Generate VSA operations figure
    print("  - Figure 5: VSA Operations")
    fig5 = create_vsa_operations_figure()
    fig5.savefig(f"{output_dir}/fig5_vsa_operations.pdf",
                 dpi=300, bbox_inches='tight', format='pdf')
    fig5.savefig(f"{output_dir}/fig5_vsa_operations.png",
                 dpi=300, bbox_inches='tight', format='png')
    plt.close(fig5)

    # Generate timeline figure
    print("  - Figure 6: Project Timeline Gantt")
    fig6 = create_timeline_gantt_figure()
    fig6.savefig(f"{output_dir}/fig6_timeline_gantt.pdf",
                 dpi=300, bbox_inches='tight', format='pdf')
    fig6.savefig(f"{output_dir}/fig6_timeline_gantt.png",
                 dpi=300, bbox_inches='tight', format='png')
    plt.close(fig6)

    # Generate risk reduction figure
    print("  - Figure 8: Risk Reduction")
    fig8 = create_risk_reduction_figure()
    fig8.savefig(f"{output_dir}/fig8_risk_reduction.pdf",
                 dpi=300, bbox_inches='tight', format='pdf')
    fig8.savefig(f"{output_dir}/fig8_risk_reduction.png",
                 dpi=300, bbox_inches='tight', format='png')
    plt.close(fig8)

    print(f"\nFigures saved to {output_dir}/:")
    print(f"  - fig4_fpga_resources.pdf/png")
    print(f"  - fig5_vsa_operations.pdf/png")
    print(f"  - fig6_timeline_gantt.pdf/png")
    print(f"  - fig8_risk_reduction.pdf/png")
    print(f"\n✅ All 8 figures complete!")


if __name__ == "__main__":
    main()
