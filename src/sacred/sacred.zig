// ═══════════════════════════════════════════════════════════════════════════════
// SACRED MODULE — Root export for all sacred mathematics
// φ² + 1/φ² = 3 = TRINITY
// ═══════════════════════════════════════════════════════════════════════════════

// Export chemistry types and functions
const chemistry = @import("chemistry.zig");
pub const Element = chemistry.Element;
pub const MolarMass = chemistry.MolarMass;
pub const getElement = chemistry.getElement;
pub const parseFormula = chemistry.parseFormula;
pub const molarMass = chemistry.molarMass;
pub const percentComposition = chemistry.percentComposition;
pub const idealGasLaw = chemistry.idealGasLaw;
pub const calculatePH = chemistry.calculatePH;
pub const calculatePOH = chemistry.calculatePOH;
pub const phToPoh = chemistry.phToPoh;
pub const pohToPh = chemistry.pohToPh;
pub const phClassification = chemistry.phClassification;
pub const bohrEnergy = chemistry.bohrEnergy;
pub const bohrRadius = chemistry.bohrRadius;
pub const hydrogenWavelength = chemistry.hydrogenWavelength;
pub const hydrogenSeries = chemistry.hydrogenSeries;

// Export temporal theory - TEMPORAL TRINITY THEOREM v1.0
const temporal_theory = @import("temporal_theory.zig");

// Re-export all temporal theory symbols
pub const TemporalTrit = temporal_theory.TemporalTrit;
pub const TemporalAspect = temporal_theory.TemporalAspect;
pub const TimeArrow = temporal_theory.TimeArrow;
pub const EternalCycle = temporal_theory.EternalCycle;
pub const PlanckTime = temporal_theory.PlanckTime;
pub const displayTemporalTheorem = temporal_theory.displayTemporalTheorem;
pub const calculateTemporalBalance = temporal_theory.calculateTemporalBalance;
pub const computeTimeArrow = temporal_theory.computeTimeArrow;
pub const computePlanckTime = temporal_theory.computePlanckTime;
pub const eternalReturn = temporal_theory.eternalReturn;
pub const verifyTrinityIdentity = temporal_theory.verifyTrinityIdentity;
