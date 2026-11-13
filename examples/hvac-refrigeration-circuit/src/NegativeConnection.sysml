// Negative connection case (documented expected failure).
// Evaporator.refrigerantOut (RefrigerantOutlet) -> Compressor.discharge (RefrigerantOutlet)
// is non-complementary. Enforced by tests/validate_hvac.ps1; current os20 check
// accepts the connect syntactically without port-kind compatibility diagnostics.
package HvacNegativeConnectionExample {

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
  part def Evaporator {
    port refrigerantIn : RefrigerantInlet;
    port refrigerantOut : RefrigerantOutlet;
  }

  part def InvalidCircuit {
    part compressor : Compressor;
    part evaporator : Evaporator;
    connect evaporator.refrigerantOut to compressor.discharge;
  }

  part invalidCircuit : InvalidCircuit;
}
