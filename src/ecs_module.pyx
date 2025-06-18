import sample.game as game
import sdk
from cpython.mem cimport PyMem_Malloc, PyMem_Free

# NOTICE: This file will be generated in the future, for now I manually wrote it for demo purposes.
# Some of this will move to a c_sdk file.

ctypedef size_t* SizeTPtr

ctypedef public void* (*get_proc_addr)(const char*)
ctypedef public int (*system_func)(const void**)

ctypedef public unsigned short ComponentId
ctypedef public unsigned long EntityId

cdef struct ComponentRef:
  ComponentId component_id
  size_t component_size
  void* component_val

ctypedef int (*for_each_t)(const void**, void*)
ctypedef int (*para_for_each_t)(const void**, const void*)

ctypedef void (*call_t)(ComponentId, const void*, size_t)
ctypedef void (*call_async_t)(ComponentId, const void*, size_t, const void*, size_t)
ctypedef void (*despawn_t)(EntityId)
ctypedef size_t (*event_count_t)(const void*)
ctypedef const unsigned long* (*event_get_t)(const void*, size_t)
ctypedef void (*event_send_t)(const void*, const char*, size_t)
ctypedef bint (*get_parent_t)(EntityId, unsigned long*)
ctypedef void (*set_parent_t)(EntityId, EntityId, bint)
ctypedef void (*set_system_enabled_t)(const char*, bint)
ctypedef EntityId (*spawn_t)(const ComponentRef*, size_t components_count)
ctypedef void (*query_for_each_t)(const void*, for_each_t, const void*)
ctypedef int (*query_get_t)(const void* arg_ptr, size_t index, const void* component_ptrs)
ctypedef int (*query_get_entity_t)(void*, EntityId, const void**)
ctypedef size_t (*query_len_t)(const void*)
ctypedef void (*query_par_for_each_t)(const void*, para_for_each_t, const void*)
ctypedef void (*add_components_t)(EntityId, size_t, const ComponentRef*, size_t)
ctypedef void (*remove_components_t)(EntityId, const ComponentId*, size_t)

ctypedef struct engine_proc_t:
  call_t call
  call_async_t call_async 
  despawn_t despawn 
  event_count_t event_count 
  event_get_t event_get 
  event_send_t event_send 
  get_parent_t get_parent 
  set_parent_t set_parent
  set_system_enabled_t set_system_enabled
  spawn_t spawn 
  query_for_each_t query_for_each 
  query_get_t query_get
  query_get_entity_t query_get_entity
  query_len_t query_len
  query_par_for_each_t query_par_for_each 
  add_components_t add_components 
  remove_components_t remove_components

cdef public enum ArgType:
  Completion
  DataAccessMut
  DataAccessRef
  EventReader
  EventWriter
  Query

cdef public enum ComponentType:
  AsyncCompletion
  Component
  Resource

# Global data
cdef engine_proc_t engine_proc
cdef dict[const char*, ComponentId] component_ids = {}

cdef dict[const char*, const char*] internal_component_id_map = {
  b"Transform": b"void_public::Transform",
  b"ColorRender": b"void_public::graphics::ColorRender",
  b"FrameConstants": b"void_public::FrameConstants",
  b"Aspect": b"void_public::Aspect",
  b"Color": b"void_public::colors::Color"
}

cdef ComponentRef build_transform_ref(data: sdk.Transform):
  cdef Transform* transform = <Transform*> PyMem_Malloc(sizeof(Transform))
  transform.position = data.position.to_tuple()
  transform.scale = data.scale.to_tuple()
  transform.pivot = data.pivot.to_tuple()
  transform.skew = data.skew.to_tuple()
  transform.rotation = data.rotation
  
  cdef ComponentRef ref 
  ref.component_id = component_ids[internal_component_id_map.get(b"Transform")]
  ref.component_size = sizeof(Transform)
  ref.component_val = transform

  return ref

cdef ComponentRef build_color_render_ref(data: sdk.ColorRender):
  cdef ColorRender* color_render = <ColorRender*> PyMem_Malloc(sizeof(ColorRender))
  color_render.visible = data.visible

  cdef ComponentRef ref 
  ref.component_id = component_ids[internal_component_id_map.get(b"ColorRender")]
  ref.component_size = sizeof(ColorRender)
  ref.component_val = color_render

  return ref

cdef ComponentRef build_star_ref(data: game.Star):
  cdef Star* star = <Star*> PyMem_Malloc(sizeof(Star))
  star.angle = data.angle if hasattr(data, "angle") else 0.0
  star.speed = data.speed if hasattr(data, "speed") else 0.0

  cdef ComponentRef ref 
  ref.component_id = component_ids[star_id]
  ref.component_size = sizeof(Star)
  ref.component_val = star

  return ref

cdef ComponentRef build_color_ref(data: sdk.Color):
  cdef Color* color = <Color*> PyMem_Malloc(sizeof(Color))
  color.r = data.r
  color.g = data.g
  color.b = data.b
  color.a = data.a

  cdef ComponentRef ref 
  ref.component_id = component_ids[internal_component_id_map.get(b"Color")]
  ref.component_size = sizeof(Color)
  ref.component_val = color

  return ref

cdef class Engine:
  cdef readonly const char* id

  def __cinit__(self):
    self.id = "engine"

  cpdef unsigned long spawn(self, list components):
    cdef int size = len(components)
    print("spawn called with size", size)
    cdef ComponentRef* bundle = <ComponentRef*> PyMem_Malloc(size * sizeof(ComponentRef))

    for i in range(size):
      component = components[i]
      id = type(component).__name__

      if id == "Transform":
        bundle[i] = build_transform_ref(component)
      elif id == "ColorRender":
        bundle[i]  = build_color_render_ref(component)
      elif id == "Color":
        bundle[i]  = build_color_ref(component)
      elif id == game.Star.__name__:
        bundle[i]  = build_star_ref(component)
      else:
        print("COMPONENT NOT FOUND", id)

    id = engine_proc.spawn(bundle, size)

    for i in range(size):
      PyMem_Free(bundle[i].component_val)

    PyMem_Free(bundle)
    return id

  def despawn(self, unsigned long id) -> int:
    print("despawn called")
    engine_proc.despawn(id)

cdef Engine engine = Engine()

# Engine Types & Components

cdef class Vec2Wrapper:
  cdef float[2]* _data

  def __repr__(self):
    return f"Vec2({self.x}, {self.y})"

  @property
  def x(self):
    return self._data[0][0]

  @x.setter
  def x(self, float value):
    self._data[0][0] = value

  @property
  def y(self):
    return self._data[0][1]

  @y.setter
  def y(self, float value):
    self._data[0][1] = value

  @staticmethod
  cdef from_ptr(float[2]* data):
    cdef Vec2Wrapper vec2 = Vec2Wrapper.__new__(Vec2Wrapper)
    vec2._data = data
    return vec2

  def __add__(self, other):
    if isinstance(other, (sdk.Vec2, Vec2Wrapper, sdk.Vec3, Vec3Wrapper)):
      self.x += other.x
      self.y += other.y
      return self

    if isinstance(other, (int, float)):
      self.x += other
      self.y += other
      return self

    raise TypeError("Unsupported operand type for +: 'Vec2' and '{}'".format(type(other)))

  def __sub__(self, other):
    if isinstance(other, (sdk.Vec2, Vec2Wrapper, sdk.Vec3, Vec3Wrapper)):
      self.x -= other.x
      self.y -= other.y
      return self

    if isinstance(other, (int, float)):
      self.x -= other
      self.y -= other
      return self

    raise TypeError("Unsupported operand type for -: 'Vec2' and '{}'".format(type(other)))

  def __mul__(self, other):
    if isinstance(other, (sdk.Vec2, Vec2Wrapper, sdk.Vec3, Vec3Wrapper)):
      self.x *= other.x
      self.y *= other.y
      return self

    if isinstance(other, (int, float)):
      self.x *= other
      self.y *= other
      return self

    raise TypeError("Unsupported operand type for *: 'Vec2' and '{}'".format(type(other)))

  def __truediv__(self, other):
    if isinstance(other, (sdk.Vec2, Vec2Wrapper, sdk.Vec3, Vec3Wrapper)):
      self.x /= other.x
      self.y /= other.y
      return self

    if isinstance(other, (int, float)):
      self.x /= other
      self.y /= other
      return self

    raise TypeError("Unsupported operand type for /: 'Vec2' and '{}'".format(type(other)))

cdef class Vec3Wrapper:
  cdef float[3]* _data

  def __repr__(self):
    return f"Vec3({self.x}, {self.y}, {self.z})"

  @property
  def x(self):
    return self._data[0][0]

  @x.setter
  def x(self, float value):
    self._data[0][0] = value

  @property
  def y(self):
    return self._data[0][1]

  @y.setter
  def y(self, float value):
    self._data[0][1] = value

  @property
  def z(self):
    return self._data[0][2]

  @z.setter
  def z(self, float value):
    self._data[0][2] = value

  @staticmethod
  cdef from_ptr(float[3]* data):
    cdef Vec3Wrapper vec3 = Vec3Wrapper.__new__(Vec3Wrapper)
    vec3._data = data
    return vec3

  def __add__(self, other):
    if isinstance(other, (sdk.Vec3, Vec3Wrapper)):
      self.x += other.x
      self.y += other.y
      self.z += other.z
      return self

    if isinstance(other, (sdk.Vec2, Vec2Wrapper)):
      self.x += other.x
      self.y += other.y
      return self

    if isinstance(other, (int, float)):
      self.x += other
      self.y += other
      self.z += other
      return self

    raise TypeError("Unsupported operand type for +: 'Vec3' and '{}'".format(type(other)))

  def __sub__(self, other):
    if isinstance(other, (sdk.Vec3, Vec3Wrapper)):
      self.x -= other.x
      self.y -= other.y
      self.z -= other.z
      return self

    if isinstance(other, (sdk.Vec2, Vec2Wrapper)):
      self.x -= other.x
      self.y -= other.y
      return self

    if isinstance(other, (int, float)):
      self.x -= other
      self.y -= other
      self.z -= other
      return self

    raise TypeError("Unsupported operand type for -: 'Vec3' and '{}'".format(type(other)))

  def __mul__(self, other):
    if isinstance(other, (sdk.Vec3, Vec3Wrapper)):
      self.x *= other.x
      self.y *= other.y
      self.z *= other.z
      return self

    if isinstance(other, (sdk.Vec2, Vec2Wrapper)):
      self.x *= other.x
      self.y *= other.y
      return self

    if isinstance(other, (int, float)):
      self.x *= other
      self.y *= other
      self.z *= other
      return self

    raise TypeError("Unsupported operand type for *: 'Vec3' and '{}'".format(type(other)))

  def __truediv__(self, other):
    if isinstance(other, (sdk.Vec3, Vec3Wrapper)):
      self.x /= other.x
      self.y /= other.y
      self.z /= other.z
      return self

    if isinstance(other, (sdk.Vec2, Vec2Wrapper)):
      self.x /= other.x
      self.y /= other.y
      return self

    if isinstance(other, (int, float)):
      self.x /= other
      self.y /= other
      self.z /= other
      return self

    raise TypeError("Unsupported operand type for /: 'Vec3' and '{}'".format(type(other)))

cdef class Vec4Wrapper:
  cdef float[4]* _data

  @property
  def x(self):
    return self._data[0][0]

  @x.setter
  def x(self, float value):
    self._data[0][0] = value

  @property
  def y(self):
    return self._data[0][1]

  @y.setter
  def y(self, float value):
    self._data[0][1] = value

  @property
  def z(self):
    return self._data[0][2]

  @z.setter
  def z(self, float value):
    self._data[0][2] = value

  @property
  def w(self):
    return self._data[0][3]

  @w.setter
  def w(self, float value):
    self._data[0][3] = value

  @staticmethod
  cdef from_ptr(float[4]* data):
    cdef Vec4Wrapper vec4 = Vec4Wrapper.__new__(Vec4Wrapper)
    vec4._data = data
    return vec4

cdef struct Color:
  float r
  float g
  float b
  float a

cdef class ColorWrapper:
  cdef Color* _data

  @property
  def r(self):
    return self._data.r

  @r.setter
  def r(self, float value):
    self._data.r = value

  @property
  def g(self):
    return self._data.g

  @g.setter
  def g(self, float value):
    self._data.g = value

  @property
  def b(self):
    return self._data.b

  @b.setter
  def b(self, float value):
    self._data.b = value

  @property
  def a(self):
    return self._data.a

  @a.setter
  def a(self, float value):
    self._data.a = value

  @staticmethod
  cdef ColorWrapper from_ptr(Color* data):
    cdef ColorWrapper wrapper = ColorWrapper.__new__(ColorWrapper)
    wrapper._data = data
    return wrapper

cdef struct Transform:
  float[3] position
  float[2] scale
  float[2] skew
  float[2] pivot
  float rotation
  float _padding

cdef class TransformWrapper:
  cdef Transform* _data

  @property
  def rotation(self):
    return self._data.rotation

  @rotation.setter
  def rotation(self, float value):
    self._data.rotation = value

  @property
  def scale(self):
    return Vec2Wrapper.from_ptr(&self._data.scale)

  @scale.setter
  def scale(self, value: sdk.Vec2 | Vec2Wrapper):
    self._data.scale = [value.x, value.y]

  @property
  def skew(self):
    return Vec2Wrapper.from_ptr(&self._data.skew)

  @skew.setter
  def skew(self, value: sdk.Vec2 | Vec2Wrapper):
    self._data.skew = [value.x, value.y]

  @property
  def pivot(self):
    return Vec2Wrapper.from_ptr(&self._data.pivot)

  @pivot.setter
  def pivot(self, value: sdk.Vec2 | Vec2Wrapper):
    self._data.pivot = [value.x, value.y]

  @property
  def position(self):
    return Vec3Wrapper.from_ptr(&self._data.position)

  @position.setter
  def position(self, value: sdk.Vec3 | Vec3Wrapper):
    self._data.position = [value.x, value.y, value.z]

  @staticmethod
  cdef TransformWrapper from_ptr(Transform* data):
    cdef TransformWrapper wrapper = TransformWrapper.__new__(TransformWrapper)
    wrapper._data = data
    return wrapper

cdef struct ColorRender:
  unsigned char visible

# Engine Resources

cdef struct FrameConstants:
  const float delta
  const float frame_rate

cdef class FrameConstantsWrapper:
  cdef readonly float delta
  cdef readonly float frame_rate

  @staticmethod
  cdef FrameConstantsWrapper from_ptr(FrameConstants* data):
    cdef FrameConstantsWrapper wrapper = FrameConstantsWrapper.__new__(FrameConstantsWrapper)
    wrapper.delta = data.delta
    wrapper.frame_rate = data.frame_rate
    return wrapper

cdef struct Aspect:
  const float width
  const float height

cdef class AspectWrapper:
  cdef readonly float width
  cdef readonly float height
  cdef readonly float left
  cdef readonly float right
  cdef readonly float bottom
  cdef readonly float top

  @staticmethod
  cdef AspectWrapper from_ptr(Aspect* data):
    cdef AspectWrapper wrapper = AspectWrapper.__new__(AspectWrapper)
    cdef float half_screen_width = data.width / 2
    cdef float half_screen_height = data.height / 2

    wrapper.width = data.width
    wrapper.height = data.height
    wrapper.right = half_screen_width
    wrapper.left = -wrapper.right
    wrapper.top = half_screen_height
    wrapper.bottom = -wrapper.top

    return wrapper

# Generated based on game code

cdef const char* star_id = "Star"
cdef size_t star_alignment = 4
cdef struct Star:    
  float angle
  float speed

cdef class StarWrapper:
  cdef Star* _data

  @property
  def angle(self):
    return self._data.angle

  @angle.setter
  def angle(self, float value):
    self._data.angle = value

  @property
  def speed(self):
    return self._data.speed

  @speed.setter
  def speed(self, float value):
    self._data.speed = value

  @staticmethod
  cdef StarWrapper from_ptr(Star* data):
    cdef StarWrapper wrapper = StarWrapper.__new__(StarWrapper)
    wrapper._data = data
    return wrapper

cdef int star_mover_wrapper(const void** system_ptr):
  cdef const void* arg_ptr = system_ptr[0]

  class QueryWrapper:
    def __init__(self):
      self.index = 0

    def __iter__(self):
      return self
      
    def __next__(self):
      count = self.length()

      if self.index >= count:
        raise StopIteration

      data = self.get(self.index)
      self.index += 1
      return data

    def length(self):
      return engine_proc.query_len(arg_ptr)

    def first(self):
      return self.get(0)

    def get(self, int index):
      count = self.length()
      if count == 0:
        return None

      if index >= count:
        print("Warning: Query.get index out of bounds. Got: ", index)
        return None

      cdef const SizeTPtr[3] ids
      cdef int code = engine_proc.query_get(arg_ptr, index, &ids)

      if code != 0:
        return None

      cdef Transform* transform = <Transform*> &ids[0][0]
      cdef Star* star = <Star*> &ids[1][0]
      cdef Color* color = <Color*> &ids[2][0]

      return [TransformWrapper.from_ptr(transform), StarWrapper.from_ptr(star), ColorWrapper.from_ptr(color)]

  game.star_mover(QueryWrapper(), FrameConstantsWrapper.from_ptr(<FrameConstants*> system_ptr[1]), AspectWrapper.from_ptr(<Aspect*> system_ptr[2]))
  return 0

cdef int spawner_wrapper(const void** system_ptr):
  game.spawner(engine, AspectWrapper.from_ptr(<Aspect*> system_ptr[1]))
  return 0

cdef int make_api_version(int major, int minor, int patch) except -1:
  return (major << 25) | (minor << 15) | patch

# Returns the engine version that we are compatible with.
cdef public int void_target_version2():
  version = make_api_version(0, 0, 12)
  print("void_target_version2 called, returning:", version)
  return version

# Sets all the component ids provided by the engine into our local cache.
cdef public void set_component_id(char* string_id, ComponentId id):
  print("set_component_id called", string_id, id)

  component_ids[string_id] = id

# Returns the component size in bytes for the provided id.
cdef public size_t component_size(char* component_id):
  print("component_size called", component_id)

  if component_id == star_id:
    return sizeof(Star)

  return 0 

# Returns the component strig id for the provided index.
cdef public const char* component_string_id(size_t component_index):
  print("component_string_id called", component_index)

  if component_index == 0:
    return star_id
  if component_index == 1:
    return engine.id

  return NULL

# Returns the component alignment for the provided id.
cdef public size_t component_align(char* string_id):
  print("component_align called", string_id)

  if string_id == star_id:
    return star_alignment

  return 0

# Returns the component type for the provided id.
cdef public ComponentType component_type(char* string_id):
  print("component_type called", string_id)

  if string_id == engine.id:
    return ComponentType.Resource

  return ComponentType.Component

# Returns the total amount of systems.
cdef public size_t systems_len():
  print("systems_len called")
  return 2

# Returns if the system should be called only once, otherwise every frame.
cdef public bint system_is_once(size_t system_index):
  print("system_is_once called", system_index)

  if system_index == 0: return False
  if system_index == 1: return True
  if system_index == 2: return True

  return False

# Returns the name of the system.
cdef public const char* system_name(size_t system_index):
  print("system_name called", system_index)

  if system_index == 0: return <bytes>game.star_mover.__name__
  if system_index == 1: return <bytes>game.spawner.__name__

  return NULL

# Returns the function for each system.
# We wrap every system function with a function that takes the pointer from the engine
# and converts it to familiar python data for the system.
cdef public system_func system_fn(size_t system_index):
  print("system_fn called", system_index)

  if system_index == 0: return star_mover_wrapper
  if system_index == 1: return spawner_wrapper

  return NULL

# Returns the number of inputs for each system.
cdef public size_t system_args_len(size_t system_index):
  print("system_args_len called", system_index)

  if system_index == 0: return 3
  if system_index == 1: return 2

  return 0

# Returns the type of input of a given system argument.
cdef public ArgType system_arg_type(size_t system_index, size_t arg_index):
  print("system_arg_type called", system_index, arg_index)

  if system_index == 0:
    if arg_index == 0:
      return ArgType.Query
    if arg_index == 1:
      return ArgType.DataAccessRef
    if arg_index == 2:
      return ArgType.DataAccessRef

  if system_index == 1:
    if arg_index == 0:
      return ArgType.DataAccessRef
    if arg_index == 1:
      return ArgType.DataAccessRef

  return ArgType.Query

# Returns the resource string id for any system inputs which are not `Query`.
cdef public const char* system_arg_component(size_t system_index, size_t arg_index):
  print("system_arg_component called", system_index, arg_index)

  if system_index == 0:
    if arg_index == 1:
      return internal_component_id_map.get(b"FrameConstants")
    if arg_index == 2:
      return internal_component_id_map.get(b"Aspect")

  if system_index == 1:
    if arg_index == 0:
      return engine.id
    if arg_index == 1:
      return internal_component_id_map.get(b"Aspect")

  return NULL

# Returns the event string id (flatbuffer's fullyQualifiedName) for the given system arg index.
cdef public const char* system_arg_event(size_t system_index, size_t arg_index):
  print("system_arg_event called", system_index, arg_index)
  return NULL

# Returns the number of inputs to each `Query`.
cdef public size_t system_query_args_len(size_t system_index, size_t arg_index):
  print("system_query_args_len called", system_index, arg_index)

  if system_index == 0:
    if arg_index == 0:
      return 3

  return 0

# Returns the type of input for each `Query` input.
cdef public ArgType system_query_arg_type(size_t system_index, size_t arg_index, size_t query_index):
  print("system_query_arg_type called", system_index, arg_index, query_index)

  # DataAccessMut for everything, except EntityId (not implemented).
  return ArgType.DataAccessMut

# Returns the component string id each `Query` input.
cdef public const char* system_query_arg_component(size_t system_index, size_t arg_index, size_t query_index):
  print("system_query_arg_component called", system_index, arg_index, query_index)
  if system_index == 0:
    if arg_index == 0:
      if query_index == 0:
        return internal_component_id_map.get(b"Transform")
      if query_index == 1:
        return star_id
      if query_index == 2:
        return internal_component_id_map.get(b"Color")

  return NULL

# Sets the pointer for every function needed in the engine.
cdef public void load_engine_proc_addrs(get_proc_addr get_proc):
  print("load_engine_proc_addrs called")
  engine_proc.call = <call_t> get_proc(<const char*>"call")
  engine_proc.call_async = <call_async_t> get_proc(<const char*>"call_async")
  engine_proc.despawn = <despawn_t> get_proc(<const char*>"despawn")
  engine_proc.event_count = <event_count_t> get_proc(<const char*>"event_count")
  engine_proc.event_get = <event_get_t> get_proc(<const char*>"event_get")
  engine_proc.event_send = <event_send_t> get_proc(<const char*>"event_send")
  engine_proc.get_parent = <get_parent_t> get_proc(<const char*>"get_parent")
  engine_proc.set_parent = <set_parent_t> get_proc(<const char*>"set_parent")
  engine_proc.set_system_enabled = <set_system_enabled_t> get_proc(<const char*>"set_system_enabled")
  engine_proc.spawn = <spawn_t> get_proc(<const char*>"spawn")
  engine_proc.query_for_each = <query_for_each_t> get_proc(<const char*>"query_for_each")
  engine_proc.query_get = <query_get_t> get_proc(<const char*>"query_get")
  engine_proc.query_get_entity = <query_get_entity_t> get_proc(<const char*>"query_get_entity")
  engine_proc.query_len = <query_len_t> get_proc(<const char*>"query_len")
  engine_proc.query_par_for_each = <query_par_for_each_t> get_proc(<const char*>"query_par_for_each")
  engine_proc.add_components = <add_components_t> get_proc(<const char*>"add_components")
  engine_proc.remove_components = <remove_components_t> get_proc(<const char*>"remove_components")
  print("load_engine_proc_addrs done setting ptrs")

# TODO: fill this in please.
cdef public const char* component_async_completion_callable(const char* string_id):
  print("component_async_completion_callable called", string_id)
  return NULL

# TODO: fill this in please.
cdef public int resource_init(char* string_id, void* val):
  print("resource_init called", string_id, val[0])
  return 0
  