// Consumer example for @example/hvac-refrigeration-circuit.
package HvacRefrigerationCircuitExample {

  item def Refrigerant;

  port def RefrigerantOutlet {
    out item fluid : Refrigerant;
  }
  port def RefrigerantInlet {
    in item fluid : Refrigerant;
  }

  part def Compressor {
    port suction : RefrigerantInlet;
    port discharge : RefrigerantOutlet;
  }
  part def Condenser {
    port refrigerantIn : RefrigerantInlet;
    port refrigerantOut : RefrigerantOutlet;
  }
  part def Evaporator {
    port refrigerantIn : RefrigerantInlet;
    port refrigerantOut : RefrigerantOutlet;
  }
  part def ExpansionValve {
    port refrigerantIn : RefrigerantInlet;
    port refrigerantOut : RefrigerantOutlet;
  }

  part def ValidCircuit {
    part compressor : Compressor;
    part condenser : Condenser;
    part expansionValve : ExpansionValve;
    part evaporator : Evaporator;

    interface dischargeLine connect compressor.discharge to condenser.refrigerantIn;
    interface liquidLine connect condenser.refrigerantOut to expansionValve.refrigerantIn;
    interface feederLine connect expansionValve.refrigerantOut to evaporator.refrigerantIn;
    interface suctionLine connect evaporator.refrigerantOut to compressor.suction;
  }

  part validCircuit : ValidCircuit;
}
