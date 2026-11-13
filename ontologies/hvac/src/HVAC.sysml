// @os20/hvac-ontology — minimal HVAC refrigeration vocabulary (v0.1.0)
// Generic engineering definitions only. Numeric catalog values live in
// ontologies/hvac/catalog/ (product-data seed), not as authoritative defaults here.
// Note: feature name `flow` is reserved in the OS20 SysML frontend — use fluid/stream.
package HVAC {

  item def Refrigerant;
  item def Air;

  port def RefrigerantOutlet {
    out item fluid : Refrigerant;
  }

  port def RefrigerantInlet {
    in item fluid : Refrigerant;
  }

  port def AirOutlet {
    out item stream : Air;
  }

  port def AirInlet {
    in item stream : Air;
  }

  // Compresses refrigerant. Suction inlet + discharge outlet.
  // Attributes (units documented; values from catalog):
  // coolingCapacity [kW], suctionDiameter [mm], dischargeDiameter [mm], ratedPower [kW]
  part def Compressor {
    port suction : RefrigerantInlet;
    port discharge : RefrigerantOutlet;
    attribute coolingCapacity;
    attribute suctionDiameter;
    attribute dischargeDiameter;
    attribute ratedPower;
  }

  // Rejects heat from refrigerant.
  // heatRejectionCapacity [kW], inletDiameter [mm], outletDiameter [mm]
  part def Condenser {
    port refrigerantIn : RefrigerantInlet;
    port refrigerantOut : RefrigerantOutlet;
    attribute heatRejectionCapacity;
    attribute inletDiameter;
    attribute outletDiameter;
  }

  // Absorbs heat into refrigerant.
  // coolingCapacity [kW], inletDiameter [mm], outletDiameter [mm]
  part def Evaporator {
    port refrigerantIn : RefrigerantInlet;
    port refrigerantOut : RefrigerantOutlet;
    attribute coolingCapacity;
    attribute inletDiameter;
    attribute outletDiameter;
  }

  // Regulates flow and drops pressure.
  // ratedCapacity [kW], inletDiameter [mm], outletDiameter [mm]
  part def ExpansionValve {
    port refrigerantIn : RefrigerantInlet;
    port refrigerantOut : RefrigerantOutlet;
    attribute ratedCapacity;
    attribute inletDiameter;
    attribute outletDiameter;
  }

  // Moves air. airflowRate [m3/s], power [W], outletDiameter [mm]
  part def Fan {
    port airIn : AirInlet;
    port airOut : AirOutlet;
    attribute airflowRate;
    attribute power;
    attribute outletDiameter;
  }

  // Positive example: vapor-compression circuit (valid refrigerant lines)
  part def RefrigerationCircuit {
    part compressor : Compressor;
    part condenser : Condenser;
    part expansionValve : ExpansionValve;
    part evaporator : Evaporator;

    interface dischargeLine connect compressor.discharge to condenser.refrigerantIn;
    interface liquidLine connect condenser.refrigerantOut to expansionValve.refrigerantIn;
    interface feederLine connect expansionValve.refrigerantOut to evaporator.refrigerantIn;
    interface suctionLine connect evaporator.refrigerantOut to compressor.suction;
  }

  // Valid air path (fan outlet -> air inlet)
  part def FanAirPath {
    part supplyFan : Fan;
    part returnFan : Fan;
    interface airTransfer connect supplyFan.airOut to returnFan.airIn;
  }
}
