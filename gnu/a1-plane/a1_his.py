"""a1_his.py <ncdump -v ... text>: A-1 metrics from D-Flow FM his (stations obs_x99, obs_x101, obs_x199)."""
import sys, re
txt = open(sys.argv[1]).read().split("data:", 1)[1]
def var(n):
    m = re.search(r"\n %s =(.*?);" % n, txt, re.S)
    return [float(v) for v in m.group(1).replace("\n", " ").split(",") if v.strip() not in ("", "_")]
t = var("time"); ns = 3
wl = var("waterlevel"); bl = var("bedlevel"); dq = var("discharge_magnitude")
h = lambda k, s: wl[k * ns + s] - bl[s]
bo, st, pr, ve = (var("water_balance_" + n) for n in ("boundaries_out", "storage", "precipitation_total", "volume_error"))
eq = [k for k, x in enumerate(t) if 1800 <= x <= 3600]
hL2 = sum((h(k, 0) + h(k, 1)) / 2 for k in eq) / len(eq)
k1 = t.index(3600.0); kN = len(t) - 1
print(f"t_end={t[-1]:.0f}s  rain={pr[kN]:.2f} m3  out(1h)={-bo[k1] if bo[k1]<0 else bo[k1]:.2f} m3  out(end)={abs(bo[kN]):.2f} m3  stored(1h)={st[k1]:.2f}  stored(end)={st[kN]:.2f}  vol_err(end)={ve[kN]:.3e} m3")
print(f"h(L/2) mean 1800-3600 = {hL2*1000:.3f} mm vs 9.373 kinematic: {(hL2*1000/9.373-1)*100:+.2f} %")
print(f"h(L/2) t=3600: {(h(k1,0)+h(k1,1))/2*1000:.3f} mm  h(x=199) t=3600: {h(k1,2)*1000:.3f} mm")
print("closure rain - out - stored(end) =", f"{pr[kN]-abs(bo[kN])-st[kN]:.4f} m3")
