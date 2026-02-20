const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

// ── Persistent chat state types ──
pub const ChatMsgType = enum {
    user,
    ai,
    log,
    // Златая Цепь — 8 chain nodes (Chakra colors)
    chain_goal_parse, // Red — Муладхара
    chain_decompose, // Orange — Свадхистана
    chain_schedule, // Yellow — Манипура
    chain_execute, // Green — Анахата
    chain_monitor, // Blue — Вишуддха
    chain_adapt, // Indigo — Аджна
    chain_synthesize, // Violet — Сахасрара
    chain_deliver, // Gold — Единство
    // Additional feedback types
    tool_result, // Tool execution
    routing_info, // Routing decision
    reflection, // Self-learning event
    agent_error, // Error
    // v1.1: Truth & Provenance
    provenance_step, // Hash chain record (steel blue)
    truth_verification, // Chain integrity verdict (bright teal)
    // v1.2: Quark-Gluon
    quark_step, // Quark sub-step record (light steel blue)
    gluon_entangle, // Gluon entanglement notification (magenta)
    // v1.4: DAG + Rewards
    dag_visualization, // DAG edge/stats summary (cyan)
    reward_summary, // $TRI reward summary (gold)
    // v1.5: Collapsible + Shareable + Staking
    collapse_toggle, // Node collapse/expand event (slate)
    share_link_generated, // Shareable link created (electric blue)
    staking_event, // Staking lock/unlock/yield event (emerald)
    // v2.0: Immortal Self-Verifying Agent
    self_repair_event, // Self-repair action (warm orange)
    immortal_persist, // Persistence checkpoint (deep teal)
    evolution_step, // Evolution generation step (aurora green)
    chain_health_check, // Chain health assessment (sky blue)
    // v2.1: Public Launch + Faucet + Canvas
    faucet_claim, // Faucet $TRI claim event (gold)
    public_launch, // Public session launch event (bright cyan)
    canvas_sync, // Canvas browser sync event (violet)
    faucet_distribution, // Faucet distribution summary (amber)
    // v2.2: Agent OS + Decentralized Network
    decentral_sync, // Multi-node sync event (electric purple)
    node_consensus, // Network consensus vote (lime green)
    network_health, // Network health report (ocean blue)
    agent_os_init, // Agent OS lifecycle event (bright coral)
    // v2.3: Mainnet Genesis + DAO + Swarm
    mainnet_genesis, // Mainnet genesis event (gold)
    dao_vote, // DAO governance vote (royal blue)
    swarm_sync, // Swarm node sync (neon green)
    token_mint, // $TRI token mint (amber)
    // v2.4: Mainnet v1.0 Launch
    mainnet_launch, // Mainnet v1.0 launch (crimson)
    community_onboard, // Community onboarding (lime)
    node_discovery, // Node discovery (cyan)
    governance_exec, // Governance execution (magenta)
    // v2.5: Immortal Agent Swarm v1.0
    swarm_orchestrate, // Swarm orchestration (electric purple)
    swarm_failover, // Swarm failover (red-orange)
    swarm_telemetry, // Swarm telemetry (teal)
    swarm_replication, // Swarm replication (sky blue)
    // v2.6: Swarm Scaling + Live Rewards + DAO Governance
    swarm_scale, // Swarm scale (gold)
    reward_distribute, // Reward distribution (amber)
    dao_governance_live, // DAO governance live (royal blue)
    node_scaling, // Node scaling (spring green)
    // v2.7: Community Nodes v1.0 + Gossip Protocol + DHT 10k+
    community_node, // Community node (lime green)
    gossip_broadcast, // Gossip broadcast (coral)
    dht_lookup, // DHT lookup (dodger blue)
    community_sync, // Community sync (medium orchid)
    // v2.8: DAO Full Governance v1.0
    dao_delegate, // DAO delegation (gold)
    timelock_vote, // Time-locked voting (crimson)
    proposal_exec, // Proposal execution (sea green)
    yield_farming, // Yield farming (dark orange)
    // v2.9: Cross-Chain Bridge v1.0
    cross_chain_bridge, // Cross-chain bridge (deep sky blue)
    atomic_swap, // Atomic swap (orange red)
    state_replicate, // State replication (medium sea green)
    bridge_sync, // Bridge sync (royal blue)
    // v2.10: Trinity DAO Full Governance v1.0 + $TRI Staking Rewards
    dao_full_governance, // DAO full governance (gold)
    tri_staking, // $TRI staking (lime green)
    reward_distribute_v2, // Reward distribution v2 (hot pink)
    staking_validate, // Staking validation (steel blue)
    // v2.11: Swarm 100k + Community 50k (Sharded Gossip + Hierarchical DHT)
    swarm_100k, // Swarm 100k (orange)
    gossip_shard, // Gossip shard (dark turquoise)
    dht_sync, // DHT hierarchical (medium purple)
    community_50k, // Community 50k (spring green)
    // v2.12: Zero-Knowledge Bridge v1.0 (ZK-Proof Verification + Privacy Transfers)
    zk_bridge, // ZK bridge (crimson)
    zk_proof, // ZK proof (electric blue)
    privacy_transfer, // Privacy transfer (indigo)
    cross_chain_sync_v2, // Cross-chain sync (emerald)
    // v2.13: Layer-2 Rollup v1.0 (u8 Upgrade)
    l2_rollup, // L2 rollup (coral)
    optimistic_verify, // Optimistic verify (cyan)
    state_channel, // State channel (orchid)
    batch_compress, // Batch compress (turquoise)
    // v2.14: Dynamic Shard Rebalancing v1.0
    dynamic_shard, // Dynamic shard (gold)
    shard_split, // Shard split (lime)
    shard_merge, // Shard merge (salmon)
    dht_adapt, // DHT adapt (steel blue)
    // v2.15: Swarm 1M + Community 500k
    swarm_million, // Swarm million (orange red)
    community_node_v2, // Community node v2 (medium purple)
    hierarchical_gossip, // Hierarchical gossip (dark cyan)
    geographic_shard, // Geographic shard (indian red)
    // v2.16: ZK-Rollup v2.0
    zk_snark_proof, // ZK-SNARK proof (lime green)
    recursive_proof, // Recursive proof (deep pink)
    l2_scaling, // L2 scaling (dodger blue)
    rollup_batch, // Rollup batch (dark orange)
    // v2.17: Cross-Shard Transactions v1.0
    cross_shard_tx, // Cross-shard transaction (spring green)
    atomic_2pc, // Atomic 2PC (hot pink)
    shard_fee, // Shard fee (steel blue)
    tx_coordinator, // Transaction coordinator (golden rod)
    // v2.18: Network Partition Recovery v1.0
    partition_detect, // Partition detection (coral #FF7F50)
    split_brain, // Split-brain detection (medium orchid #BA55D3)
    auto_heal, // Auto-healing (medium sea green #3CB371)
    partition_tolerance, // Partition tolerance (slate blue #6A5ACD)
    // v2.19: Swarm 10M + Community 5M
    swarm_10m, // Swarm 10M (lime green #32CD32)
    community_5m, // Community 5M (deep pink #FF1493)
    earning_boost, // Earning boost (dodger blue #1E90FF)
    massive_gossip, // Massive gossip (dark orange #FF8C00)
    // v2.20: ZK-Rollup v2.0
    zk_rollup_v2, // ZK-Rollup v2 (medium spring green #00FA9A)
    snark_generate, // SNARK generation (hot pink #FF69B4)
    recursive_compose, // Recursive composition (royal blue #4169E1)
    l2_fee_collect, // L2 fee collection (gold #FFD700)
    // v2.21: Cross-Shard Transactions v1.0
    cross_shard_tx_v2, // Cross-shard tx v2 (cyan #00FFFF)
    atomic_2pc_v2, // Atomic 2PC v2 (magenta #FF00FF)
    shard_fee_v2, // Shard fee v2 (orange red #FF4500)
    inter_shard_sync_v2, // Inter-shard sync v2 (spring green #00FF7F)
    // v2.22: Formal Verification v1.0
    formal_verify_v2, // Formal verify v2 (deep sky blue #00BFFF)
    property_test_v2, // Property test v2 (deep pink #FF1493)
    invariant_check_v2, // Invariant check v2 (lime green #32CD32)
    proof_generate_v2, // Proof generate v2 (orange #FFA500)
    // v2.23: Swarm 100M + Community 50M
    swarm_100m_v2,
    community_50m_v2,
    earning_moonshot_v2,
    gossip_v3_v2,
    // v2.24: Trinity Global Dominance v1.0
    global_dominance_v2,
    world_adoption_v2,
    tri_to_one_v2,
    ecosystem_complete_v2,

    // v2.25: Trinity Eternal v1.0
    ouroboros_evolve_v2,
    infinite_scale_v2,
    universal_reserve_v2,
    eternal_uptime_v2,

    // v2.26: $TRI to $10
    tri_to_ten_v2,
    mass_adoption_v2,
    exchange_listing_v2,
    universal_wallet_v2,

    // v2.27: Trinity Beyond v1.0
    tri_to_hundred_v2,
    universal_adoption_v2,
    exchange_v2_v2,
    global_wallet_v2,
    // v2.28: Swarm 10M + u8 FULL
    swarm_10m_v2,
    community_5m_v2,
    earning_ultimate_v2,
    node_discovery_10m_v2,
    // v2.29: u16 Upgrade canvas types
    swarm_1b_v2,
    community_500m_v2,
    earning_god_mode_v2,
    node_discovery_1b_v2,
    // v2.30: Trinity Neural Network v1.0
    ternary_nn_v2,
    recursive_self_train_v2,
    contribution_reward_v2,
    neural_consensus_v2,
    // v2.31: $TRI to $1000 + Eternal Dominance
    tri_to_1000_v2,
    universal_reserve_v2_v2,
    global_dominance_v2_v2,
    eternal_governance_v2_v2,
    // v2.32: Trinity Beyond v1.0
    trinity_beyond_v2,
    infinite_scale_v2_v2,
    multiverse_dominance_v2,
    eternal_evolution_v2,
    // v3.0: Trinity Absolute v1.0
    trinity_absolute_v3,
    infinite_tri_v3,
    eternal_victory_v3,
    multiverse_complete_v3,
};

// ── v1.9: Emergent Wave Mode (replaces panel system) ──
pub const WaveMode = enum {
    idle, // 27 petals logo — main menu
    chat, // Fullscreen chat wave field
    code, // Fullscreen code editor wave field
    tools, // Fullscreen tools wave field
    settings, // Fullscreen settings wave field
    vision, // Fullscreen vision wave field
    voice, // Fullscreen voice wave field
    finder, // Fullscreen finder wave field
    docs, // Fullscreen docs wave field
    mirror, // v2.1: Mirror of Three Worlds dashboard
    depin, // v2.4: DePIN Node control panel
    ralph, // v2.9: Ralph Autonomous Monitor panel

    pub fn getLabel(self: WaveMode) [*:0]const u8 {
        return switch (self) {
            .idle => "TRINITY",
            .chat => "CHAT",
            .code => "CODE",
            .tools => "TOOLS",
            .settings => "SETTINGS",
            .vision => "VISION",
            .voice => "VOICE",
            .finder => "FINDER",
            .docs => "DOCS",
            .mirror => "MIRROR",
            .depin => "DEPIN",
            .ralph => "RALPH",
        };
    }

    pub fn getHue(self: WaveMode) f32 {
        return switch (self) {
            .idle => 45.0, // Gold
            .chat => 150.0, // Green
            .code => 210.0, // Blue
            .tools => 30.0, // Orange
            .settings => 270.0, // Purple
            .vision => 180.0, // Cyan
            .voice => 330.0, // Pink
            .finder => 60.0, // Yellow
            .docs => 120.0, // Green-light
            .mirror => 45.0, // Gold (Trinity)
            .depin => 90.0, // Green-yellow (earning)
            .ralph => 200.0, // Cyan-blue (autonomous)
        };
    }
};

// ── v2.9: Circuit breaker tri-state (RALPH-CANVAS-004) ──
pub const CircuitBreakerState = enum {
    closed, // Normal operation (green)
    degraded, // Warning state (yellow)
    cb_open, // Circuit open, halted (red)

    pub fn getColor(self: CircuitBreakerState, a: u8) rl.Color {
        return switch (self) {
            .closed => rl.Color{ .r = 0x00, .g = 0xCC, .b = 0x66, .a = a },
            .degraded => rl.Color{ .r = 0xFF, .g = 0xCC, .b = 0x00, .a = a },
            .cb_open => rl.Color{ .r = 0xFF, .g = 0x33, .b = 0x33, .a = a },
        };
    }

    pub fn getLabel(self: CircuitBreakerState) [*:0]const u8 {
        return switch (self) {
            .closed => "CLOSED",
            .degraded => "DEGRADED",
            .cb_open => "OPEN",
        };
    }
};

// ── Unified Chat Message types ──
pub const ChatSender = enum { loop, claude };
pub const ChatMsgKind = enum { log_line, claude_result, task_list, meta_info };

pub const ChatMsg = struct {
    sender: ChatSender = .loop,
    kind: ChatMsgKind = .log_line,
    timestamp: i64 = 0,
    text: [256:0]u8 = [_:0]u8{0} ** 256,
    text_len: usize = 0,
    result_offset: usize = 0,
    result_len: usize = 0,
    todo_count: usize = 0,
    tag_r: u8 = 0xBB,
    tag_g: u8 = 0xBB,
    tag_b: u8 = 0xBB,
    show_full: bool = false,
};
