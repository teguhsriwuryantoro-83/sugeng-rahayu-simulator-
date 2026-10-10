extends Node3D

var speed_kmh := 65.0
var distance_km := 0.0
var driving := true
var camera_index := 0
var camera: Camera3D
var road: MeshInstance3D
var vehicle_anchor: Node3D
var label: Label
var stripe_nodes: Array[Node3D] = []
var world_speed := 0.0

func _ready() -> void:
    _create_environment()
    _create_ui()

func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
    var mesh := MeshInstance3D.new()
    var shape := BoxMesh.new()
    shape.size = size
    mesh.mesh = shape
    mesh.position = pos
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    mesh.material_override = material
    parent.add_child(mesh)
    return mesh

func _create_environment() -> void:
    var env := WorldEnvironment.new()
    var resource := Environment.new()
    resource.background_mode = Environment.BG_COLOR
    resource.background_color = Color(0.53, 0.75, 0.91)
    resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    resource.ambient_light_color = Color(0.8, 0.85, 0.9)
    env.environment = resource
    add_child(env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-40, -30, 0)
    sun.light_energy = 1.2
    add_child(sun)
    _box(self, Vector3(100, .1, 1400), Vector3(0, -.13, -520), Color(.25, .43, .24))
    road = _box(self, Vector3(14, .12, 1400), Vector3(0, -.05, -520), Color(.21, .23, .26))
    for i in range(95):
        var stripe := _box(self, Vector3(.16, .025, 4), Vector3(0, .035, 15 - i * 12), Color(.95, .92, .78))
        stripe_nodes.append(stripe)
    vehicle_anchor = Node3D.new()
    vehicle_anchor.name = "BusModelAnchor"
    add_child(vehicle_anchor)
    # A precise licensed GLB must be placed in res://assets/bus.glb.
    # No fake cuboid coach is substituted when the asset is absent.
    if ResourceLoader.exists("res://assets/bus.glb"):
        var model = load("res://assets/bus.glb").instantiate()
        vehicle_anchor.add_child(model)
    camera = Camera3D.new()
    camera.current = true
    add_child(camera)
    _set_camera()

func _set_camera() -> void:
    match camera_index:
        0:
            camera.position = Vector3(8, 6, 15)
            camera.look_at(Vector3(0, 2, -5))
        1:
            camera.position = Vector3(0, 3.1, -1)
            camera.look_at(Vector3(0, 2, -28))
        2:
            camera.position = Vector3(-11, 5, 0)
            camera.look_at(Vector3(0, 2, -4))
        _:
            camera.position = Vector3(0, 11, 17)
            camera.look_at(Vector3(0, 0, -5))

func _create_ui() -> void:
    var canvas := CanvasLayer.new()
    add_child(canvas)
    var root := VBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
    canvas.add_child(root)
    label = Label.new()
    label.text = "SUGENG RAHAYU | MODEL 3D BELUM DIUNGGAH"
    label.add_theme_font_size_override("font_size", 18)
    root.add_child(label)
    var row := HBoxContainer.new()
    root.add_child(row)
    for action in ["JALAN/JEDA", "KAMERA", "LEBIH CEPAT", "LEBIH LAMBAT"]:
        var button := Button.new()
        button.text = action
        row.add_child(button)
        button.pressed.connect(_on_action.bind(action))

func _on_action(action: String) -> void:
    match action:
        "JALAN/JEDA":
            driving = not driving
        "KAMERA":
            camera_index = (camera_index + 1) % 4
            _set_camera()
        "LEBIH CEPAT":
            speed_kmh = minf(speed_kmh + 10, 100)
        "LEBIH LAMBAT":
            speed_kmh = maxf(speed_kmh - 10, 0)

func _process(delta: float) -> void:
    world_speed = speed_kmh / 3.6 if driving else 0.0
    distance_km += world_speed * delta / 1000.0
    for stripe in stripe_nodes:
        stripe.position.z += world_speed * delta
        if stripe.position.z > 22:
            stripe.position.z -= 1140
    label.text = "SUGENG RAHAYU | %d KM/JAM | %.2f KM | MODEL GLB BELUM TERSEDIA" % [int(world_speed * 3.6), distance_km]
