import pcbnew

board = pcbnew.LoadBoard("/Users/ken/Projects/map-controllor/pcb/encoder.kicad_pcb")

for fp in board.GetFootprints():
    print(f"== {fp.GetValue()} ref={fp.GetReference()} at={fp.GetPosition()} rot={fp.GetOrientationDegrees()}")
    for pad in fp.Pads():
        p = pad.GetPosition()
        print(f"  pad {pad.GetNumber():>5} global=({p.x/1e6:.2f}, {p.y/1e6:.2f}) mm")
