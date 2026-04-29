import { useState } from “react”;

const tabs = [“Combat”, “Visuals”, “World”, “Character”, “Options”, “Configs”, “NPC”, “Teams”];

// ── Combat sub-tabs
const combatLeftTabs = [“Aimbot”, “Prediction”, “Smoothness”, “FOV”];
const combatRightTabs = [“Silent Aim”, “Prediction”, “FOV”];

// ── Visuals sub-tabs
const visualsLeftTabs = [“ESP”, “Crosshair”, “Misc”, “Flags”];
const visualsRightTabs = [“Indicators”, “OOF Arrow”, “Radar”];

// ── World sub-tabs
const worldLeftTabs = [“Camera”, “Freecam”];

// ── helpers
function Toggle({ checked, onChange }) {
return (
<div
onClick={() => onChange(!checked)}
style={{
width: 14, height: 14, border: “1.5px solid #555”,
background: checked ? “#c084fc” : “transparent”,
borderRadius: 3, cursor: “pointer”, flexShrink: 0,
display: “flex”, alignItems: “center”, justifyContent: “center”,
}}
>
{checked && <div style={{ width: 7, height: 7, background: “#fff”, borderRadius: 1 }} />}
</div>
);
}

function Slider({ value, onChange, min = 0, max = 1000, color = “#e879f9” }) {
const pct = ((value - min) / (max - min)) * 100;
return (
<div style={{ position: “relative”, height: 4, background: “#2a2a2a”, borderRadius: 2, cursor: “pointer” }}
onClick={e => {
const rect = e.currentTarget.getBoundingClientRect();
const p = (e.clientX - rect.left) / rect.width;
onChange(Math.round(min + p * (max - min)));
}}>
<div style={{ position: “absolute”, left: 0, width: pct + “%”, height: “100%”, background: color, borderRadius: 2 }} />
<div style={{
position: “absolute”, left: pct + “%”, top: “50%”,
transform: “translate(-50%,-50%)”,
width: 10, height: 10, borderRadius: “50%”, background: color, border: “2px solid #1a1a1a”
}} />
</div>
);
}

function Select({ value, onChange, options }) {
return (
<select value={value} onChange={e => onChange(e.target.value)}
style={{
width: “100%”, background: “#1e1e1e”, border: “1px solid #333”,
color: “#ccc”, padding: “4px 8px”, borderRadius: 4, fontSize: 11,
cursor: “pointer”, outline: “none”
}}>
{options.map(o => <option key={o}>{o}</option>)}
</select>
);
}

function Row({ label, children, value }) {
return (
<div style={{ display: “flex”, alignItems: “center”, justifyContent: “space-between”, marginBottom: 6 }}>
<span style={{ fontSize: 11, color: “#aaa” }}>{label}</span>
<div style={{ display: “flex”, alignItems: “center”, gap: 6 }}>
{value !== undefined && <span style={{ fontSize: 10, color: “#666”, minWidth: 24, textAlign: “right” }}>{value}</span>}
{children}
</div>
</div>
);
}

function Section({ title, children }) {
return (
<div style={{ marginBottom: 10 }}>
{title && <div style={{ fontSize: 10, color: “#666”, marginBottom: 5, textTransform: “uppercase”, letterSpacing: 1 }}>{title}</div>}
{children}
</div>
);
}

function SubTabBar({ tabs, active, onSelect, color = “#c084fc” }) {
return (
<div style={{ display: “flex”, gap: 2, marginBottom: 12, borderBottom: “1px solid #222”, paddingBottom: 6 }}>
{tabs.map(t => (
<button key={t} onClick={() => onSelect(t)} style={{
background: “none”, border: “none”, cursor: “pointer”,
fontSize: 10, color: active === t ? color : “#555”,
padding: “2px 6px”, borderBottom: active === t ? `1.5px solid ${color}` : “none”,
transition: “color .15s”
}}>{t}</button>
))}
</div>
);
}

// ══════════ COMBAT PANEL ══════════
function CombatPanel() {
const [leftTab, setLeftTab] = useState(“Aimbot”);
const [rightTab, setRightTab] = useState(“Silent Aim”);
const [ab, setAb] = useState({
enabled: false, teamCheck: false, visibleCheck: false, healthCheck: false, stickyAim: false,
dist: 500, sens: 0.40, hitPart: “Head”, aimType: “Mouse”, rageMethod: false, type: “Camera Teleport”, resolver: false
});
const [sa, setSa] = useState({
enabled: false, teamCheck: false, visibleCheck: false, healthCheck: false, stickyAim: false,
dist: 500, hitPart: “Head”, method: “Experimental”
});
const [tb, setTb] = useState({
enabled: false, visibleCheck: false, teamCheck: false, hitboxMul: 1.00, delay: 1, release: 10
});

return (
<div style={{ display: “flex”, gap: 16 }}>
{/* LEFT */}
<div style={{ flex: 1 }}>
<SubTabBar tabs={combatLeftTabs} active={leftTab} onSelect={setLeftTab} />
{leftTab === “Aimbot” && (
<>
<Row label="Enabled"><Toggle checked={ab.enabled} onChange={v => setAb({ …ab, enabled: v })} /></Row>
<Row label="Team Check"><Toggle checked={ab.teamCheck} onChange={v => setAb({ …ab, teamCheck: v })} /></Row>
<Row label="Visible Check"><Toggle checked={ab.visibleCheck} onChange={v => setAb({ …ab, visibleCheck: v })} /></Row>
<Row label="Health Check"><Toggle checked={ab.healthCheck} onChange={v => setAb({ …ab, healthCheck: v })} /></Row>
<Row label="Sticky Aim"><Toggle checked={ab.stickyAim} onChange={v => setAb({ …ab, stickyAim: v })} /></Row>
<Row label="Distance" value={ab.dist} />
<div style={{ marginBottom: 10 }}><Slider value={ab.dist} onChange={v => setAb({ …ab, dist: v })} min={0} max={1000} color=”#e879f9” /></div>
<Row label="Sensitivity" value={ab.sens.toFixed(2)} />
<div style={{ marginBottom: 10 }}><Slider value={ab.sens * 100} onChange={v => setAb({ …ab, sens: v / 100 })} min={0} max={100} color=”#e879f9” /></div>
<div style={{ fontSize: 10, color: “#666”, marginBottom: 4 }}>Hit Part</div>
<div style={{ marginBottom: 8 }}><Select value={ab.hitPart} onChange={v => setAb({ …ab, hitPart: v })} options={[“Head”, “Torso”, “Left Arm”, “Right Arm”, “Left Leg”, “Right Leg”]} /></div>
<div style={{ fontSize: 10, color: “#666”, marginBottom: 4 }}>Aim Type</div>
<div style={{ marginBottom: 8 }}><Select value={ab.aimType} onChange={v => setAb({ …ab, aimType: v })} options={[“Mouse”, “Gyroscope”, “Camera”]} /></div>
<Row label="Rage Method"><Toggle checked={ab.rageMethod} onChange={v => setAb({ …ab, rageMethod: v })} /></Row>
<div style={{ fontSize: 10, color: “#666”, marginBottom: 4 }}>Type</div>
<div style={{ marginBottom: 8 }}><Select value={ab.type} onChange={v => setAb({ …ab, type: v })} options={[“Camera Teleport”, “Silent”, “Legit”]} /></div>
<div style={{ borderTop: “1px solid #222”, paddingTop: 8, marginTop: 4 }}>
<span style={{ fontSize: 10, color: “#666” }}>Misc</span>
<div style={{ marginTop: 6 }}><Row label="Resolver"><Toggle checked={ab.resolver} onChange={v => setAb({ …ab, resolver: v })} /></Row></div>
</div>
</>
)}
</div>

```
  {/* RIGHT */}
  <div style={{ flex: 1 }}>
    <SubTabBar tabs={combatRightTabs} active={rightTab} onSelect={setRightTab} color="#f472b6" />
    {rightTab === "Silent Aim" && (
      <>
        <Row label="Enabled"><Toggle checked={sa.enabled} onChange={v => setSa({ ...sa, enabled: v })} /></Row>
        <Row label="Team Check"><Toggle checked={sa.teamCheck} onChange={v => setSa({ ...sa, teamCheck: v })} /></Row>
        <Row label="Visible Check"><Toggle checked={sa.visibleCheck} onChange={v => setSa({ ...sa, visibleCheck: v })} /></Row>
        <Row label="Health Check"><Toggle checked={sa.healthCheck} onChange={v => setSa({ ...sa, healthCheck: v })} /></Row>
        <Row label="Sticky Aim"><Toggle checked={sa.stickyAim} onChange={v => setSa({ ...sa, stickyAim: v })} /></Row>
        <Row label="Distance" value={sa.dist} />
        <div style={{ marginBottom: 10 }}><Slider value={sa.dist} onChange={v => setSa({ ...sa, dist: v })} min={0} max={1000} color="#f472b6" /></div>
        <div style={{ fontSize: 10, color: "#666", marginBottom: 4 }}>Hit Part</div>
        <div style={{ marginBottom: 8 }}><Select value={sa.hitPart} onChange={v => setSa({ ...sa, hitPart: v })} options={["Head", "Torso", "Left Arm", "Right Arm"]} /></div>
        <div style={{ fontSize: 10, color: "#666", marginBottom: 4 }}>Methods</div>
        <div style={{ marginBottom: 12 }}><Select value={sa.method} onChange={v => setSa({ ...sa, method: v })} options={["Experimental", "Standard", "Legacy"]} /></div>

        <div style={{ borderTop: "1px solid #222", paddingTop: 8 }}>
          <div style={{ fontSize: 10, color: "#666", marginBottom: 6 }}>Trigger Bot</div>
          <Row label="Enabled"><Toggle checked={tb.enabled} onChange={v => setTb({ ...tb, enabled: v })} /></Row>
          <Row label="Visible Check"><Toggle checked={tb.visibleCheck} onChange={v => setTb({ ...tb, visibleCheck: v })} /></Row>
          <Row label="Team Check"><Toggle checked={tb.teamCheck} onChange={v => setTb({ ...tb, teamCheck: v })} /></Row>
          <Row label="Hitbox Mul" value={tb.hitboxMul.toFixed(2)} />
          <div style={{ marginBottom: 8 }}><Slider value={tb.hitboxMul * 100} onChange={v => setTb({ ...tb, hitboxMul: v / 100 })} min={100} max={300} color="#f472b6" /></div>
          <Row label="Delay (ms)" value={tb.delay} />
          <div style={{ marginBottom: 8 }}><Slider value={tb.delay} onChange={v => setTb({ ...tb, delay: v })} min={0} max={500} color="#f472b6" /></div>
          <Row label="Release (ms)" value={tb.release} />
          <div style={{ marginBottom: 8 }}><Slider value={tb.release} onChange={v => setTb({ ...tb, release: v })} min={0} max={200} color="#f472b6" /></div>
        </div>
      </>
    )}
  </div>
</div>
```

);
}

// ══════════ VISUALS PANEL ══════════
function VisualsPanel() {
const [leftTab, setLeftTab] = useState(“ESP”);
const [rightTab, setRightTab] = useState(“Indicators”);
const [esp, setEsp] = useState({
enabled: false, teamCheck: false, visibleCheck: false, teamBasedColor: false,
textGradient: true, textBackground: false, outline: true, glow: false, selfESP: false,
sizingType: “Bounding”, renderDist: 3000,
boxEnabled: false, fillBox: false, boxType: “2D”,
nameEnabled: false,
healthBar: false, healthBased: false, healthText: false, textPos: “Above Name”,
chamsEnabled: false, chamsFilled: true, renderingType: “Static”,
tracerEnabled: false,
distance: false, equippedItem: false, skeleton: false, headDot: false, headDotGlow: false, profilePic: false,
});

return (
<div style={{ display: “flex”, gap: 16 }}>
<div style={{ flex: 1 }}>
<SubTabBar tabs={visualsLeftTabs} active={leftTab} onSelect={setLeftTab} />
{leftTab === “ESP” && (
<>
<Row label="Enabled"><Toggle checked={esp.enabled} onChange={v => setEsp({ …esp, enabled: v })} /></Row>
<Row label="Team Check"><Toggle checked={esp.teamCheck} onChange={v => setEsp({ …esp, teamCheck: v })} /></Row>
<Row label="Visible Check"><Toggle checked={esp.visibleCheck} onChange={v => setEsp({ …esp, visibleCheck: v })} /></Row>
<Row label="Team Based Color"><Toggle checked={esp.teamBasedColor} onChange={v => setEsp({ …esp, teamBasedColor: v })} /></Row>
<Row label="Text Gradient" ><Toggle checked={esp.textGradient} onChange={v => setEsp({ …esp, textGradient: v })} /></Row>
<Row label="Text Background"><Toggle checked={esp.textBackground} onChange={v => setEsp({ …esp, textBackground: v })} /></Row>
<Row label="Outline"><Toggle checked={esp.outline} onChange={v => setEsp({ …esp, outline: v })} /></Row>
<Row label="Glow"><Toggle checked={esp.glow} onChange={v => setEsp({ …esp, glow: v })} /></Row>
<Row label="Self ESP"><Toggle checked={esp.selfESP} onChange={v => setEsp({ …esp, selfESP: v })} /></Row>
<div style={{ fontSize: 10, color: “#666”, marginBottom: 4 }}>Sizing Type</div>
<div style={{ marginBottom: 8 }}><Select value={esp.sizingType} onChange={v => setEsp({ …esp, sizingType: v })} options={[“Bounding”, “Dynamic”, “Static”]} /></div>
<Row label="Render Distance" value={esp.renderDist} />
<div style={{ marginBottom: 10 }}><Slider value={esp.renderDist} onChange={v => setEsp({ …esp, renderDist: v })} min={0} max={5000} color=”#e879f9” /></div>

```
        <Section title="Box">
          <Row label="Enabled"><Toggle checked={esp.boxEnabled} onChange={v => setEsp({ ...esp, boxEnabled: v })} /></Row>
          <Row label="Fill Box"><Toggle checked={esp.fillBox} onChange={v => setEsp({ ...esp, fillBox: v })} /></Row>
          <div style={{ fontSize: 10, color: "#666", marginBottom: 4 }}>Box Type</div>
          <div style={{ marginBottom: 8 }}><Select value={esp.boxType} onChange={v => setEsp({ ...esp, boxType: v })} options={["2D", "3D", "Corner"]} /></div>
        </Section>

        <Section title="Name">
          <Row label="Enabled"><Toggle checked={esp.nameEnabled} onChange={v => setEsp({ ...esp, nameEnabled: v })} /></Row>
        </Section>
      </>
    )}
  </div>

  <div style={{ flex: 1 }}>
    <SubTabBar tabs={visualsRightTabs} active={rightTab} onSelect={setRightTab} color="#f472b6" />
    {rightTab === "Indicators" && (
      <>
        <Row label="Distance"><Toggle checked={esp.distance} onChange={v => setEsp({ ...esp, distance: v })} /></Row>
        <Row label="Equipped Item"><Toggle checked={esp.equippedItem} onChange={v => setEsp({ ...esp, equippedItem: v })} /></Row>
        <Row label="Skeleton"><Toggle checked={esp.skeleton} onChange={v => setEsp({ ...esp, skeleton: v })} /></Row>
        <Row label="Head Dot"><Toggle checked={esp.headDot} onChange={v => setEsp({ ...esp, headDot: v })} /></Row>
        <Row label="Head Dot Glow"><Toggle checked={esp.headDotGlow} onChange={v => setEsp({ ...esp, headDotGlow: v })} /></Row>
        <Row label="Profile Picture"><Toggle checked={esp.profilePic} onChange={v => setEsp({ ...esp, profilePic: v })} /></Row>

        <Section title="Health">
          <Row label="Health Bar"><Toggle checked={esp.healthBar} onChange={v => setEsp({ ...esp, healthBar: v })} /></Row>
          <Row label="Health Based"><Toggle checked={esp.healthBased} onChange={v => setEsp({ ...esp, healthBased: v })} /></Row>
          <Row label="Health Text"><Toggle checked={esp.healthText} onChange={v => setEsp({ ...esp, healthText: v })} /></Row>
          <div style={{ fontSize: 10, color: "#666", marginBottom: 4 }}>Text Pos</div>
          <div style={{ marginBottom: 8 }}><Select value={esp.textPos} onChange={v => setEsp({ ...esp, textPos: v })} options={["Above Name", "Below Name", "Left", "Right"]} /></div>
        </Section>

        <Section title="Chams">
          <Row label="Enabled"><Toggle checked={esp.chamsEnabled} onChange={v => setEsp({ ...esp, chamsEnabled: v })} /></Row>
          <Row label="Filled"><Toggle checked={esp.chamsFilled} onChange={v => setEsp({ ...esp, chamsFilled: v })} /></Row>
          <div style={{ fontSize: 10, color: "#666", marginBottom: 4 }}>Rendering Type</div>
          <div style={{ marginBottom: 8 }}><Select value={esp.renderingType} onChange={v => setEsp({ ...esp, renderingType: v })} options={["Static", "Dynamic", "Wireframe"]} /></div>
        </Section>

        <Section title="Tracer">
          <Row label="Enabled"><Toggle checked={esp.tracerEnabled} onChange={v => setEsp({ ...esp, tracerEnabled: v })} /></Row>
        </Section>
      </>
    )}
  </div>
</div>
```

);
}

// ══════════ WORLD PANEL ══════════
function WorldPanel() {
const [leftTab, setLeftTab] = useState(“Camera”);
const [w, setW] = useState({
cameraFOV: false, fovAmount: 70,
waypointName: “”, tweenGoto: false, tweenSpeed: 200,
visualizeWaypoint: false,
ambience: false, customFog: false, glow: false, distance: 0,
customExposure: false, exposureComp: 2.00,
customBrightness: false, brightness: 2.00,
customTime: false, clockTime: 12.00,
customSky: false, sky: “Galaxy Nebula”,
});

return (
<div style={{ display: “flex”, gap: 16 }}>
<div style={{ flex: 1 }}>
<SubTabBar tabs={worldLeftTabs} active={leftTab} onSelect={setLeftTab} />
{leftTab === “Camera” && (
<>
<Row label="Camera Field Of View"><Toggle checked={w.cameraFOV} onChange={v => setW({ …w, cameraFOV: v })} /></Row>
<Row label="Amount" value={w.fovAmount} />
<div style={{ marginBottom: 12 }}><Slider value={w.fovAmount} onChange={v => setW({ …w, fovAmount: v })} min={30} max={120} color=”#e879f9” /></div>

```
        <Section title="Waypoint">
          <div style={{ fontSize: 10, color: "#666", marginBottom: 4 }}>Name</div>
          <input value={w.waypointName} onChange={e => setW({ ...w, waypointName: e.target.value })}
            style={{ width: "100%", background: "#1e1e1e", border: "1px solid #333", color: "#ccc", padding: "4px 8px", borderRadius: 4, fontSize: 11, marginBottom: 6, boxSizing: "border-box" }} />
          <button style={{ width: "100%", background: "#2a2a2a", border: "1px solid #444", color: "#ccc", padding: "5px", borderRadius: 4, fontSize: 11, cursor: "pointer", marginBottom: 4 }}>Create</button>
          <div style={{ fontSize: 10, color: "#e879f9", marginBottom: 4 }}>No Saved Waypoints</div>
          <button style={{ width: "100%", background: "#2a2a2a", border: "1px solid #444", color: "#ccc", padding: "5px", borderRadius: 4, fontSize: 11, cursor: "pointer", marginBottom: 4 }}>Remove Waypoint</button>
          <button style={{ width: "100%", background: "#2a2a2a", border: "1px solid #444", color: "#ccc", padding: "5px", borderRadius: 4, fontSize: 11, cursor: "pointer", marginBottom: 8 }}>Goto</button>
          <Row label="Tween goto"><Toggle checked={w.tweenGoto} onChange={v => setW({ ...w, tweenGoto: v })} /></Row>
          <Row label="Tween speed" value={w.tweenSpeed.toFixed(2)} />
          <div style={{ marginBottom: 8 }}><Slider value={w.tweenSpeed} onChange={v => setW({ ...w, tweenSpeed: v })} min={1} max={1000} color="#e879f9" /></div>
          <Row label="Visualize waypoint"><Toggle checked={w.visualizeWaypoint} onChange={v => setW({ ...w, visualizeWaypoint: v })} /></Row>
        </Section>
      </>
    )}
  </div>

  <div style={{ flex: 1 }}>
    <div style={{ fontSize: 10, color: "#666", marginBottom: 8, textTransform: "uppercase", letterSpacing: 1 }}>World Lighting</div>
    <Row label="Ambience"><Toggle checked={w.ambience} onChange={v => setW({ ...w, ambience: v })} /></Row>
    <Row label="Custom Fog"><Toggle checked={w.customFog} onChange={v => setW({ ...w, customFog: v })} /></Row>
    <Row label="Glow"><Toggle checked={w.glow} onChange={v => setW({ ...w, glow: v })} /></Row>
    <Row label="Distance" value={w.distance} />
    <div style={{ marginBottom: 10 }}><Slider value={w.distance} onChange={v => setW({ ...w, distance: v })} min={0} max={1000} color="#e879f9" /></div>

    <Row label="Custom Exposure"><Toggle checked={w.customExposure} onChange={v => setW({ ...w, customExposure: v })} /></Row>
    <Row label="Exposure Compensation" value={w.exposureComp.toFixed(2)} />
    <div style={{ marginBottom: 10 }}><Slider value={w.exposureComp * 100} onChange={v => setW({ ...w, exposureComp: v / 100 })} min={0} max={500} color="#e879f9" /></div>

    <Row label="Custom Brightness"><Toggle checked={w.customBrightness} onChange={v => setW({ ...w, customBrightness: v })} /></Row>
    <Row label="Brightness" value={w.brightness.toFixed(2)} />
    <div style={{ marginBottom: 10 }}><Slider value={w.brightness * 100} onChange={v => setW({ ...w, brightness: v / 100 })} min={0} max={500} color="#e879f9" /></div>

    <Row label="Custom Time"><Toggle checked={w.customTime} onChange={v => setW({ ...w, customTime: v })} /></Row>
    <Row label="Clock Time" value={w.clockTime.toFixed(2)} />
    <div style={{ marginBottom: 10 }}><Slider value={w.clockTime} onChange={v => setW({ ...w, clockTime: v })} min={0} max={24} color="#e879f9" /></div>

    <Row label="Custom Sky"><Toggle checked={w.customSky} onChange={v => setW({ ...w, customSky: v })} /></Row>
    <div style={{ fontSize: 10, color: "#666", marginBottom: 4 }}>Sky</div>
    <Select value={w.sky} onChange={v => setW({ ...w, sky: v })} options={["Galaxy Nebula", "Bluesky", "Night", "Sunset", "Cloudy"]} />
  </div>
</div>
```

);
}

// ══════════ CHARACTER PANEL ══════════
function CharacterPanel() {
const [c, setC] = useState({
hitboxEnabled: true, visualizeHitbox: false, teamCheck: false, healthCheck: false,
hitboxSize: 20, hitboxType: “Old”,
targetHoveringEnabled: false, displayCircle: false, targetMethod: “Closest To Mouse”,
radius: 10, speed: 5.60,
desyncEnabled: false, desyncMethod: “Client-Sided”,
removeWalkAnim: false, disableAnimation: false, useTick: false,
antiFling: false, noClip: false, infJump: false, clickTP: false,
speedEnabled: false, speedMethod: “Velocity”, speedAmount: 1,
flightEnabled: false, flightMethod: “Velocity”, flightAmount: 1,
jumpEnabled: false, jumpPower: 50,
floatEnabled: false, floatHeight: 10,
timerEnabled: false, timerMultiply: 1.00,
});

return (
<div style={{ display: “flex”, gap: 16 }}>
<div style={{ flex: 1 }}>
<Section title="Hitbox Extender">
<Row label="Enabled"><Toggle checked={c.hitboxEnabled} onChange={v => setC({ …c, hitboxEnabled: v })} /></Row>
<Row label="Visualize Hitbox"><Toggle checked={c.visualizeHitbox} onChange={v => setC({ …c, visualizeHitbox: v })} /></Row>
<Row label="Team Check"><Toggle checked={c.teamCheck} onChange={v => setC({ …c, teamCheck: v })} /></Row>
<Row label="Health Check"><Toggle checked={c.healthCheck} onChange={v => setC({ …c, healthCheck: v })} /></Row>
<Row label="Hitbox Size" value={c.hitboxSize} />
<div style={{ marginBottom: 8 }}><Slider value={c.hitboxSize} onChange={v => setC({ …c, hitboxSize: v })} min={1} max={100} color=”#e879f9” /></div>
<div style={{ fontSize: 10, color: “#666”, marginBottom: 4 }}>Type</div>
<div style={{ marginBottom: 10 }}><Select value={c.hitboxType} onChange={v => setC({ …c, hitboxType: v })} options={[“Old”, “New”, “Hybrid”]} /></div>
</Section>

```
    <Section title="Target Hovering">
      <Row label="Enabled"><Toggle checked={c.targetHoveringEnabled} onChange={v => setC({ ...c, targetHoveringEnabled: v })} /></Row>
      <Row label="Display Circle"><Toggle checked={c.displayCircle} onChange={v => setC({ ...c, displayCircle: v })} /></Row>
      <div style={{ fontSize: 10, color: "#666", marginBottom: 4 }}>Target Method</div>
      <div style={{ marginBottom: 8 }}><Select value={c.targetMethod} onChange={v => setC({ ...c, targetMethod: v })} options={["Closest To Mouse", "Closest To Center", "Random"]} /></div>
      <Row label="Radius" value={c.radius.toFixed(2)} />
      <div style={{ marginBottom: 8 }}><Slider value={c.radius} onChange={v => setC({ ...c, radius: v })} min={0} max={50} color="#e879f9" /></div>
      <Row label="Speed" value={c.speed.toFixed(2)} />
      <div style={{ marginBottom: 8 }}><Slider value={c.speed * 100} onChange={v => setC({ ...c, speed: v / 100 })} min={0} max={2000} color="#e879f9" /></div>
    </Section>

    <Section title="Desync">
      <Row label="Enabled"><Toggle checked={c.desyncEnabled} onChange={v => setC({ ...c, desyncEnabled: v })} /></Row>
      <div style={{ fontSize: 10, color: "#666", marginBottom: 4 }}>Method</div>
      <div style={{ marginBottom: 8 }}><Select value={c.desyncMethod} onChange={v => setC({ ...c, desyncMethod: v })} options={["Client-Sided", "Server-Sided", "Hybrid"]} /></div>
      <Row label="Remove Walk Animation"><Toggle checked={c.removeWalkAnim} onChange={v => setC({ ...c, removeWalkAnim: v })} /></Row>
      <Row label="Disable Animation"><Toggle checked={c.disableAnimation} onChange={v => setC({ ...c, disableAnimation: v })} /></Row>
      <Row label="Use Tick"><Toggle checked={c.useTick} onChange={v => setC({ ...c, useTick: v })} /></Row>
    </Section>
  </div>

  <div style={{ flex: 1 }}>
    <Section title="Movement">
      <Row label="Anti-Fling"><Toggle checked={c.antiFling} onChange={v => setC({ ...c, antiFling: v })} /></Row>
      <Row label="No-Clip"><Toggle checked={c.noClip} onChange={v => setC({ ...c, noClip: v })} /></Row>
      <Row label="Inf Jump"><Toggle checked={c.infJump} onChange={v => setC({ ...c, infJump: v })} /></Row>
      <Row label="Click TP"><Toggle checked={c.clickTP} onChange={v => setC({ ...c, clickTP: v })} /></Row>
      <Row label="Speed"><Toggle checked={c.speedEnabled} onChange={v => setC({ ...c, speedEnabled: v })} /></Row>
      <div style={{ fontSize: 10, color: "#666", marginBottom: 4 }}>Speed Method</div>
      <div style={{ marginBottom: 8 }}><Select value={c.speedMethod} onChange={v => setC({ ...c, speedMethod: v })} options={["Velocity", "BodyVelocity", "Fly"]} /></div>
      <Row label="Speed Amount" value={c.speedAmount} />
      <div style={{ marginBottom: 10 }}><Slider value={c.speedAmount} onChange={v => setC({ ...c, speedAmount: v })} min={1} max={200} color="#e879f9" /></div>
    </Section>

    <Section title="">
      <Row label="Flight"><Toggle checked={c.flightEnabled} onChange={v => setC({ ...c, flightEnabled: v })} /></Row>
      <div style={{ fontSize: 10, color: "#666", marginBottom: 4 }}>Flight Method</div>
      <div style={{ marginBottom: 8 }}><Select value={c.flightMethod} onChange={v => setC({ ...c, flightMethod: v })} options={["Velocity", "BodyVelocity", "Noclip"]} /></div>
      <Row label="Flight Amount" value={c.flightAmount} />
      <div style={{ marginBottom: 10 }}><Slider value={c.flightAmount} onChange={v => setC({ ...c, flightAmount: v })} min={1} max={200} color="#e879f9" /></div>

      <Row label="Jump"><Toggle checked={c.jumpEnabled} onChange={v => setC({ ...c, jumpEnabled: v })} /></Row>
      <Row label="Jump Power" value={c.jumpPower} />
      <div style={{ marginBottom: 10 }}><Slider value={c.jumpPower} onChange={v => setC({ ...c, jumpPower: v })} min={1} max={500} color="#e879f9" /></div>

      <Row label="Float"><Toggle checked={c.floatEnabled} onChange={v => setC({ ...c, floatEnabled: v })} /></Row>
      <Row label="Height" value={c.floatHeight} />
      <div style={{ marginBottom: 10 }}><Slider value={c.floatHeight} onChange={v => setC({ ...c, floatHeight: v })} min={0} max={100} color="#e879f9" /></div>
    </Section>

    <Section title="Timer Manipulation">
      <Row label="Enabled"><Toggle checked={c.timerEnabled} onChange={v => setC({ ...c, timerEnabled: v })} /></Row>
      <Row label="Multiply" value={c.timerMultiply.toFixed(2)} />
      <div style={{ marginBottom: 8 }}><Slider value={c.timerMultiply * 100} onChange={v => setC({ ...c, timerMultiply: v / 100 })} min={0} max={500} color="#e879f9" /></div>
    </Section>
  </div>
</div>
```

);
}

// ══════════ MAIN APP ══════════
export default function MatchaExternal() {
const [tab, setTab] = useState(“Combat”);

return (
<div style={{
minHeight: “100vh”, background: “#0d0d0d”, display: “flex”,
alignItems: “center”, justifyContent: “center”,
fontFamily: “‘Segoe UI’, sans-serif”,
}}>
<div style={{
width: 740, background: “#141414”, border: “1px solid #2a2a2a”,
borderRadius: 10, overflow: “hidden”,
boxShadow: “0 0 40px rgba(232,121,249,0.08), 0 0 0 1px #1e1e1e”,
}}>
{/* Title bar */}
<div style={{
display: “flex”, alignItems: “center”, justifyContent: “space-between”,
padding: “8px 14px”, borderBottom: “1px solid #1e1e1e”,
background: “#111”
}}>
<div style={{ display: “flex”, gap: 10 }}>
{[“Matcha”, “Interface”, “Pro”].map((t, i) => (
<span key={t} style={{
fontSize: 11, color: i === 0 ? “#e879f9” : i === 1 ? “#aaa” : “#e879f9”,
fontWeight: i === 2 ? 700 : 400
}}>{t}</span>
))}
</div>
<span style={{ fontSize: 10, color: “#555” }}>OlemadLaptop</span>
</div>

```
    {/* Main tabs */}
    <div style={{ display: "flex", borderBottom: "1px solid #1e1e1e", background: "#111" }}>
      {tabs.map(t => (
        <button key={t} onClick={() => setTab(t)} style={{
          background: "none", border: "none", cursor: "pointer",
          fontSize: 11, padding: "8px 14px",
          color: tab === t ? "#e879f9" : "#555",
          borderBottom: tab === t ? "2px solid #e879f9" : "2px solid transparent",
          transition: "color .15s, border-color .15s"
        }}>{t}</button>
      ))}
    </div>

    {/* Content */}
    <div style={{ padding: "14px 16px", maxHeight: 520, overflowY: "auto" }}>
      {tab === "Combat" && <CombatPanel />}
      {tab === "Visuals" && <VisualsPanel />}
      {tab === "World" && <WorldPanel />}
      {tab === "Character" && <CharacterPanel />}
      {!["Combat", "Visuals", "World", "Character"].includes(tab) && (
        <div style={{ color: "#444", fontSize: 12, padding: "40px 0", textAlign: "center" }}>
          {tab} — coming soon
        </div>
      )}
    </div>

    {/* Footer */}
    <div style={{
      display: "flex", justifyContent: "space-between", alignItems: "center",
      padding: "6px 14px", borderTop: "1px solid #1e1e1e", background: "#0f0f0f"
    }}>
      <span style={{ fontSize: 10, color: "#444" }}>● 4159 online</span>
      <span style={{ fontSize: 10, color: "#444" }}>matcha.pink/discord</span>
      <span style={{ fontSize: 10, color: "#444" }}>Build: Apr 10 2026</span>
    </div>
  </div>
</div>
```

);
}
