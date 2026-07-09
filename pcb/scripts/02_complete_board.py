# encoder.kicad_pcb を完成させるスクリプト (KiCad 10 の pcbnew API を使用)
# - リファレンス設定 (U1 / SW1)
# - ネット作成とパッドへの割り当て
# - F.Cu / B.Cu の2層で配線
# - 基板外形 (84,59)-(116,116) と M3 取付穴 x4
# - B.Cu に GND ベタ
import pcbnew
from pcbnew import FromMM, VECTOR2I

PCB = "/Users/ken/Projects/map-controllor/pcb/encoder.kicad_pcb"
TRACK_W = FromMM(0.3)
VIA_SIZE = FromMM(0.6)
VIA_DRILL = FromMM(0.3)


def mm(x, y):
    return VECTOR2I(FromMM(x), FromMM(y))


board = pcbnew.LoadBoard(PCB)

# --- footprints ---
xiao = None
sw = None
for fp in board.GetFootprints():
    if fp.GetValue() == "Xiao2040":
        xiao = fp
    elif fp.GetValue() == "RKJXT1F42001":
        sw = fp
assert xiao and sw

xiao.SetReference("U1")
sw.SetReference("SW1")


def pad_of(fp, number):
    for p in fp.Pads():
        if p.GetNumber() == number:
            return p
    raise KeyError(number)


# --- nets ---
net_names = ["GND", "SW_A", "SW_B", "SW_C", "SW_D", "SW_PUSH", "ENC_A", "ENC_B"]
nets = {}
for name in net_names:
    n = pcbnew.NETINFO_ITEM(board, name)
    board.Add(n)
    nets[name] = n

# XIAO: pad1=GP26 pad2=GP27 pad3=GP28 pad4=GP29 pad5=GP6 pad6=GP7 pad7=GP0 pad13=GND
assign = [
    (xiao, "1", "SW_A"), (xiao, "2", "SW_B"), (xiao, "3", "SW_C"),
    (xiao, "4", "SW_D"), (xiao, "5", "SW_PUSH"),
    (xiao, "6", "ENC_A"), (xiao, "7", "ENC_B"), (xiao, "13", "GND"),
    (sw, "A", "SW_A"), (sw, "B", "SW_B"), (sw, "C", "SW_C"), (sw, "D", "SW_D"),
    (sw, "Push", "SW_PUSH"), (sw, "EA", "ENC_A"), (sw, "EB", "ENC_B"),
    (sw, "Com", "GND"), (sw, "ECom", "GND"), (sw, "GND", "GND"),
]
for fp, num, net in assign:
    pad_of(fp, num).SetNet(nets[net])


def track(net, layer, *points):
    for a, b in zip(points, points[1:]):
        t = pcbnew.PCB_TRACK(board)
        t.SetStart(mm(*a))
        t.SetEnd(mm(*b))
        t.SetWidth(TRACK_W)
        t.SetLayer(layer)
        t.SetNet(nets[net])
        board.Add(t)


def via(net, x, y):
    v = pcbnew.PCB_VIA(board)
    v.SetPosition(mm(x, y))
    v.SetViaType(pcbnew.VIATYPE_THROUGH)
    v.SetDrill(VIA_DRILL)
    try:
        v.SetWidth(VIA_SIZE)
    except TypeError:
        v.SetWidth(pcbnew.PADSTACK.ALL_LAYERS, VIA_SIZE)
    v.SetLayerPair(pcbnew.F_Cu, pcbnew.B_Cu)
    v.SetNet(nets[net])
    board.Add(v)


F = pcbnew.F_Cu
B = pcbnew.B_Cu

# --- 配線 ---
# SW_A: U1 pad1 (92.38,67.38) -> SW1 A (98.5,107.8)  左端チャネル x=88.0
track("SW_A", F, (92.38, 67.38), (88.0, 67.38), (88.0, 110.8))
via("SW_A", 88.0, 110.8)
track("SW_A", B, (88.0, 110.8), (98.5, 110.8))
via("SW_A", 98.5, 110.8)
track("SW_A", F, (98.5, 110.8), (98.5, 107.8))

# SW_D: U1 pad4 (92.38,75.04) -> SW1 D (92.2,98.5)  チャネル x=88.7
track("SW_D", F, (92.38, 75.04), (88.7, 75.04), (88.7, 98.5))
via("SW_D", 88.7, 98.5)
track("SW_D", B, (88.7, 98.5), (92.2, 98.5))

# SW_PUSH: U1 pad5 (92.38,77.54) -> SW1 Push (101.0,106.98)  チャネル x=89.4
track("SW_PUSH", F, (92.38, 77.54), (89.4, 77.54), (89.4, 109.9))
via("SW_PUSH", 89.4, 109.9)
track("SW_PUSH", B, (89.4, 109.9), (101.0, 109.9), (101.0, 106.98))

# ENC_A: U1 pad6 (92.38,80.08) -> SW1 EA (92.2,101.5)  チャネル x=90.1
track("ENC_A", F, (92.38, 80.08), (90.1, 80.08), (90.1, 101.5), (92.2, 101.5))

# ENC_B: U1 pad7 (92.38,82.62) -> SW1 EB (107.8,98.5)  下をくぐって右回り
track("ENC_B", F, (92.38, 82.62), (92.38, 87.5))
via("ENC_B", 92.38, 87.5)
track("ENC_B", B, (92.38, 87.5), (111.0, 87.5), (111.0, 98.5), (107.8, 98.5))

# SW_C: U1 pad3 (92.38,72.46) -> SW1 C (101.5,92.2)  中央を直行
track("SW_C", F, (92.38, 72.46), (101.5, 72.46), (101.5, 92.2))

# SW_B: U1 pad2 (92.38,69.92) -> SW1 B (107.8,101.5)  中央右を下降
track("SW_B", F, (92.38, 69.92), (104.5, 69.92), (104.5, 101.5), (107.8, 101.5))

# GND: U1 pad13 (107.62,69.92) -> SW1 GND (106.86,103.75) -> Com (99.0,94.22) -> ECom (98.5,92.2)
track("GND", F, (107.62, 69.92), (109.5, 69.92), (109.5, 103.75), (106.86, 103.75))
track("GND", B, (106.86, 103.75), (99.0, 94.22), (98.5, 92.2))

# --- 基板外形 ---
outline = pcbnew.PCB_SHAPE(board)
outline.SetShape(pcbnew.SHAPE_T_RECT)
outline.SetStart(mm(84, 59))
outline.SetEnd(mm(116, 116))
outline.SetLayer(pcbnew.Edge_Cuts)
outline.SetWidth(FromMM(0.1))
board.Add(outline)

# --- M3 取付穴 (Edge.Cuts の円 = 基板カット穴, 径3.2mm) ---
for hx, hy in [(87, 62), (113, 62), (87, 113), (113, 113)]:
    hole = pcbnew.PCB_SHAPE(board)
    hole.SetShape(pcbnew.SHAPE_T_CIRCLE)
    hole.SetStart(mm(hx, hy))          # 中心
    hole.SetEnd(mm(hx + 1.6, hy))      # 半径1.6mm
    hole.SetLayer(pcbnew.Edge_Cuts)
    hole.SetWidth(FromMM(0.1))
    board.Add(hole)

# --- B.Cu の GND ベタ ---
zone = pcbnew.ZONE(board)
zone.SetLayer(pcbnew.B_Cu)
zone.SetNet(nets["GND"])
zone.SetLocalClearance(FromMM(0.3))
zone.SetMinThickness(FromMM(0.25))
zone.SetPadConnection(pcbnew.ZONE_CONNECTION_THERMAL)
poly = zone.Outline()
poly.NewOutline()
for px, py in [(84, 59), (116, 59), (116, 116), (84, 116)]:
    poly.Append(FromMM(px), FromMM(py))
board.Add(zone)

filler = pcbnew.ZONE_FILLER(board)
filler.Fill(board.Zones())

pcbnew.SaveBoard(PCB, board)
print("saved", PCB)
