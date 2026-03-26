#!/usr/bin/env python3
"""
DARPA CLARA Proposal — Architecture Figure Generator

Generates Figure 1: Trinity S³AI Framework Architecture diagram
showing the relationship between all 7 bundles and supporting layer.

Usage:
    python generate_architecture_figure.py

Output:
    figures/fig1_system_architecture.pdf
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import numpy as np

# Trinity S³AI Bundle Configuration
BUNDLES = [
    {"id": "B001", "name": "HSLM", "desc": "Ternary Language Model", "color": "#2563EB"},
    {"id": "B002", "name": "FPGA", "desc": "Zero-DSP Inference", "color": "#7C3AED"},
    {"id": "B003", "name": "TRI-27", "desc": "ISA Interpreter", "color": "#EC4899"},
    {"id": "B007", "name": "VSA", "desc": "Vector Symbolic Architecture", "color": "#8B5CF6"},
    {"id": "B004", "name": "Queen", "desc": "RL Q-values, 5-Cycle", "color": "#F59E0B"},
    {"id": "B005", "name": "VIBEE", "desc": "tri→verilog Compiler", "color": "#10B981"},
    {"id": "B006", "name": "Sacred", "desc": "GF16/TF3, φ-math", "color": "#06B6D4"},
]

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

def draw_arrow(ax, x1, y1, x2, y2, style='->'):
    """Draw an arrow between two points."""
    arrow = FancyArrowPatch((x1, y1), (x2, y2),
                            arrowstyle=style,
                            mutation_scale=15,
                            color='#374151',
                            linewidth=2)
    ax.add_patch(arrow)

def create_architecture_diagram():
    """
    Create the Trinity S³AI system architecture diagram.
    """
    fig, ax = plt.subplots(figsize=(12, 8))

    # Main container - Trinity S³AI Framework
    main_box = FancyBboxPatch((0.5, 3.5), 11, 4,
                               boxstyle="round,pad=0.1",
                               facecolor='#F3F4F6',
                               edgecolor='#1F2937',
                               linewidth=3)
    ax.add_patch(main_box)
    ax.text(6, 7.3, "Trinity S³AI Framework",
            ha='center', va='center',
            fontsize=16, fontweight='bold',
            color='#1F2937')

    # Core Layer - 4 main bundles
    core_y = 5.8
    core_boxes = [
        (1.5, core_y, 2, 0.7, BUNDLES[0]),  # B001 HSLM
        (4.5, core_y, 2, 0.7, BUNDLES[3]),  # B007 VSA
        (7.5, core_y, 2, 0.7, BUNDLES[2]),  # B003 TRI-27
    ]

    for x, y, w, h, bundle in core_boxes:
        rounded_box(ax, x, y, w, h, bundle["color"],
                   f"{bundle['id']}: {bundle['name']}\n{bundle['desc']}")

    # Arrows to FPGA layer
    for x, y, w, h, _ in core_boxes:
        draw_arrow(ax, x + w/2, y, 5.5, 4.5)

    # FPGA Layer
    fpga_y = 4.2
    rounded_box(ax, 4.5, fpga_y, 3, 0.7, BUNDLES[1]["color"],
               f"{BUNDLES[1]['id']}: {BUNDLES[1]['name']}\n{BUNDLES[1]['desc']}")

    # Arrow to Queen
    draw_arrow(ax, 6, fpga_y, 6, 3.8)

    # Queen Layer
    queen_y = 3.0
    rounded_box(ax, 4.5, queen_y, 3, 0.7, BUNDLES[4]["color"],
               f"{BUNDLES[4]['id']}: {BUNDLES[4]['name']}\n{BUNDLES[4]['desc']}")

    # Supporting Layer - 3 supporting bundles
    support_y = 1.8
    support_boxes = [
        (1.5, support_y, 2.5, 0.6, BUNDLES[5]),  # B005 VIBEE
        (4.75, support_y, 2.5, 0.6, BUNDLES[6]), # B006 Sacred
        (8, support_y, 2.5, 0.6, "#9CA3AF"),    # Calibration
    ]

    # Supporting container
    support_container = FancyBboxPatch((1, 1.2), 10, 1.6,
                                       boxstyle="round,pad=0.05",
                                       facecolor='#E5E7EB',
                                       edgecolor='#6B7280',
                                       linewidth=2,
                                       linestyle='--')
    ax.add_patch(support_container)
    ax.text(6, 2.65, "Supporting Layer",
            ha='center', va='center',
            fontsize=11, fontweight='bold',
            color='#4B5563')

    for x, y, w, h, bundle in support_boxes:
        if isinstance(bundle, dict):
            rounded_box(ax, x, y, w, h, bundle["color"],
                       f"{bundle['id']}: {bundle['name']}\n{bundle['desc']}")
        else:
            rounded_box(ax, x, y, w, h, bundle,
                       "Calibration\nECE/Brier Metrics",
                       text_color="#1F2937")

    # Annotations
    ax.text(0.5, 6.5, "Core Layer",
            ha='right', va='center',
            fontsize=10, fontweight='bold',
            color='#6B7280', rotation=90)

    ax.text(0.5, 4.5, "Hardware",
            ha='right', va='center',
            fontsize=10, fontweight='bold',
            color='#6B7280', rotation=90)

    ax.text(0.5, 3.3, "Orchestration",
            ha='right', va='center',
            fontsize=10, fontweight='bold',
            color='#6B7280', rotation=90)

    # Styling
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.set_aspect('equal')
    ax.axis('off')

    # Title
    ax.text(6, 7.7, "Figure 1: Trinity S³AI Framework Architecture",
            ha='center', va='center',
            fontsize=14, fontweight='bold',
            color='#1F2937')

    return fig


def create_bundle_comparison_diagram():
    """
    Create a comparison diagram showing all 7 bundles.
    """
    fig, ax = plt.subplots(figsize=(12, 6))

    # Bundle data for visualization
    bundle_info = [
        ("B001\nHSLM", "1.95M\nparams", "385\nKB", "0.084\nECE"),
        ("B002\nFPGA", "0%\nDSP", "1.2\nW", "0.092\nECE"),
        ("B003\nTRI-27", "36\nopcodes", "27\nregs", "0.115\nECE"),
        ("B004\nQueen", "5-cycle\nRL", "Q-values", "0.108\nECE"),
        ("B005\nVIBEE", "tri→\nverilog", "compiler", "0.065\nECE"),
        ("B006\nSacred", "GF16/\nTF3", "φ-math", "0.071\nECE"),
        ("B007\nVSA", "10K\ndim", "FHRR", "0.065\nECE"),
    ]

    x_positions = np.arange(len(bundle_info))
    bar_width = 0.6

    # Draw bundles as colored bars
    for i, (name, metric1, metric2, metric3) in enumerate(bundle_info):
        color = BUNDLES[i]["color"] if i < len(BUNDLES) else "#9CA3AF"

        # Main bundle box
        ax.bar(i, 1, bar_width, color=color, alpha=0.8, edgecolor='black')

        # Labels
        ax.text(i, 0.5, name, ha='center', va='center',
                fontsize=10, fontweight='bold', color='white')

        # Metric labels above
        ax.text(i, 1.1, metric1, ha='center', va='bottom',
                fontsize=7, color='#374151')
        ax.text(i, 1.25, metric2, ha='center', va='bottom',
                fontsize=7, color='#374151')
        ax.text(i, 1.4, metric3, ha='center', va='bottom',
                fontsize=8, fontweight='bold', color='#2563EB')

    ax.set_xlim(-0.5, len(bundle_info) - 0.5)
    ax.set_ylim(0, 1.6)
    ax.set_xticks(x_positions)
    ax.set_xticklabels([])
    ax.set_yticks([])
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.spines['bottom'].set_visible(False)

    # Title
    ax.text(len(bundle_info)/2 - 0.5, 1.8,
            "Figure 7: Trinity S³AI Bundle Overview — All 7 Bundles Calibrated",
            ha='center', va='center',
            fontsize=13, fontweight='bold',
            color='#1F2937')

    return fig


def create_ternary_comparison_figure():
    """
    Create a comparison figure: Ternary vs Binary vs FP32.
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Data
    models = ['FP32\nBaseline', 'Binary\n(BitNet)', 'Ternary\n(Trinity)']
    sizes = [7.6, 3.8, 0.385]  # MB
    ppl = [118.0, 128.0, 122.3]  # PPL

    # Colors
    colors = ['#9CA3AF', '#F59E0B', '#2563EB']

    # Left: Model size comparison (bar chart, log scale)
    bars1 = ax1.bar(range(3), sizes, color=colors, alpha=0.8, edgecolor='black')
    ax1.set_ylabel('Model Size (MB)', fontsize=11, fontweight='bold')
    ax1.set_title('Model Size Comparison', fontsize=12, fontweight='bold')
    ax1.set_xticks(range(3))
    ax1.set_xticklabels(models)
    ax1.set_yscale('log')
    ax1.grid(axis='y', alpha=0.3)

    # Add value labels on bars
    for i, (bar, size) in enumerate(zip(bars1, sizes)):
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2, height,
                f'{size} MB',
                ha='center', va='bottom', fontsize=10, fontweight='bold')

    # Annotation: 19.7× compression
    ax1.annotate('19.7×\ncompression',
                xy=(2, 0.385), xytext=(1, 2),
                arrowprops=dict(arrowstyle='->', color='#2563EB', lw=2),
                fontsize=10, fontweight='bold', color='#2563EB',
                ha='center')

    # Right: Size vs Accuracy scatter
    ax2.scatter(sizes, ppl, s=500, c=colors, alpha=0.8, edgecolors='black', linewidth=2)
    ax2.set_xlabel('Model Size (MB)', fontsize=11, fontweight='bold')
    ax2.set_ylabel('TinyStories PPL', fontsize=11, fontweight='bold')
    ax2.set_title('Size vs Accuracy Trade-off', fontsize=12, fontweight='bold')
    ax2.set_xscale('log')
    ax2.grid(alpha=0.3)

    # Add model labels
    for i, (size, ppl_val, model) in enumerate(zip(sizes, ppl, models)):
        ax2.annotate(model.split('\n')[0],
                    xy=(size, ppl_val),
                    xytext=(10, 10), textcoords='offset points',
                    fontsize=9, fontweight='bold',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))

    # Annotation
    ax2.annotate('<5% accuracy loss\nvs FP32',
                xy=(0.385, 122.3), xytext=(1, 118),
                arrowprops=dict(arrowstyle='->', color='#10B981', lw=2),
                fontsize=9, fontweight='bold', color='#10B981',
                ha='center')

    fig.suptitle('Figure 2: Ternary vs Binary Neural Network Comparison',
                fontsize=14, fontweight='bold', y=1.02)

    return fig


def main():
    """
    Generate all architecture and comparison figures.
    """
    import os

    # Create output directory
    output_dir = "figures"
    os.makedirs(output_dir, exist_ok=True)

    print("Generating architecture figures...")

    # Generate architecture diagram
    print("  - Figure 1: System Architecture")
    fig1 = create_architecture_diagram()
    fig1.savefig(f"{output_dir}/fig1_system_architecture.pdf",
                 dpi=300, bbox_inches='tight', format='pdf')
    fig1.savefig(f"{output_dir}/fig1_system_architecture.png",
                 dpi=300, bbox_inches='tight', format='png')
    plt.close(fig1)

    # Generate bundle overview
    print("  - Figure 7: Bundle Overview")
    fig2 = create_bundle_comparison_diagram()
    fig2.savefig(f"{output_dir}/fig7_bundle_overview.pdf",
                 dpi=300, bbox_inches='tight', format='pdf')
    fig2.savefig(f"{output_dir}/fig7_bundle_overview.png",
                 dpi=300, bbox_inches='tight', format='png')
    plt.close(fig2)

    # Generate ternary comparison
    print("  - Figure 2: Ternary Comparison")
    fig3 = create_ternary_comparison_figure()
    fig3.savefig(f"{output_dir}/fig2_ternary_comparison.pdf",
                 dpi=300, bbox_inches='tight', format='pdf')
    fig3.savefig(f"{output_dir}/fig2_ternary_comparison.png",
                 dpi=300, bbox_inches='tight', format='png')
    plt.close(fig3)

    print(f"\nFigures saved to {output_dir}/:")
    print(f"  - fig1_system_architecture.pdf/png")
    print(f"  - fig2_ternary_comparison.pdf/png")
    print(f"  - fig7_bundle_overview.pdf/png")


if __name__ == "__main__":
    main()
