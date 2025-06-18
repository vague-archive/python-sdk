from typing import Callable, Optional, List
import functools
import math

# This file holds a sample SDK.
# Functions needed to build a game and interact with our Engine and ECS.

u8 = int
u16 = int
u32 = int
u64 = int
i8 = int
i16 = int
i32 = int
i64 = int
f32 = float
f64 = float


class Vec2:
  x: float
  y: float

  def __init__( self, x: float = 0.0, y: float = 0.0):
    self.x = x
    self.y = y

  def to_tuple(self) -> tuple[float, float]:
    return [self.x, self.y]
  
  def __repr__(self):
    return f"Vec2({self.x}, {self.y})"
  
  def __add__(self, other):
    if isinstance(other, (Vec2, Vec3)):
      self.x += other.x
      self.y += other.y
      return self

    if isinstance(other, (int, float)):
      self.x += other
      self.y += other
      return self

    raise TypeError("Unsupported operand type for +: 'Vec2' and '{}'".format(type(other)))

  def __sub__(self, other):
    if isinstance(other, (Vec2, Vec3)):
      self.x -= other.x
      self.y -= other.y
      return self

    if isinstance(other, (int, float)):
      self.x -= other
      self.y -= other
      return self

    raise TypeError("Unsupported operand type for -: 'Vec2' and '{}'".format(type(other)))

  def __mul__(self, other):
    if isinstance(other, (Vec2, Vec3)):
      self.x *= other.x
      self.y *= other.y
      return self

    if isinstance(other, (int, float)):
      self.x *= other
      self.y *= other
      return self

    raise TypeError("Unsupported operand type for *: 'Vec2' and '{}'".format(type(other)))

  def __truediv__(self, other):
    if isinstance(other, (Vec2, Vec3)):
      self.x /= other.x
      self.y /= other.y
      return self

    if isinstance(other, (int, float)):
      self.x /= other
      self.y /= other
      return self
      
    raise TypeError("Unsupported operand type for /: 'Vec2' and '{}'".format(type(other)))


class Vec3:
  x: float
  y: float
  z: float

  def __init__( self, x: float = 0.0, y: float = 0.0, z: float = 0.0):
    self.x = x
    self.y = y
    self.z = z

  def to_tuple(self) -> tuple[float, float, float]:
    return [self.x, self.y, self.z]
  
  def __repr__(self):
    return f"Vec3({self.x}, {self.y})"
  
  def __add__(self, other):
    if isinstance(other, Vec3):
      self.x += other.x
      self.y += other.y
      self.z += other.z
      return self

    if isinstance(other, Vec2):
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
    if isinstance(other, Vec3):
      self.x -= other.x
      self.y -= other.y
      self.z -= other.z
      return self

    if isinstance(other, Vec2):
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
    if isinstance(other, Vec3):
      self.x *= other.x
      self.y *= other.y
      self.z *= other.z
      return self

    if isinstance(other, Vec2):
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
    if isinstance(other, Vec3):
      self.x /= other.x
      self.y /= other.y
      self.z /= other.z
      return self

    if isinstance(other, Vec2):
      self.x /= other.x
      self.y /= other.y
      return self

    if isinstance(other, (int, float)):
      self.x /= other
      self.y /= other
      self.z /= other
      return self
      
    raise TypeError("Unsupported operand type for /: 'Vec3' and '{}'".format(type(other)))


class Vec4:
  x: float
  y: float
  z: float
  w: float

  def __init__( self, x: float = 0.0, y: float = 0.0, z: float = 0.0, w: float = 0.0):
    self.x = x
    self.y = y
    self.z = z
    self.w = w

  def to_tuple(self) -> tuple[float, float, float, float]:
    return [self.x, self.y, self.z, self.w]


class Color:
  r: float
  g: float
  b: float
  a: float

  def __init__( self, r: float = 1.0, g: float = 1.0, b: float = 1.0, a: float = 1.0):
    self.r = r
    self.g = g
    self.b = b
    self.a = a

  def to_tuple(self) -> tuple[float, float, float, float]:
    return [self.r, self.g, self.b, self.a]


class Query[*QueryArgs]:
  def first(self) -> Optional[tuple[*QueryArgs]]: pass
  def get(self, index: int) -> Optional[tuple[*QueryArgs]]: pass
  def length(self) -> int: pass
  def __iter__(self) -> "Query[*QueryArgs]": pass
  def __next__(self) -> tuple[*QueryArgs]: pass


def system(func):
  @functools.wraps(func)
  def wrapper(*args, **kwargs):
    return func(*args, **kwargs)
  return wrapper


def system_once(func):
  @functools.wraps(func)
  def wrapper(*args, **kwargs):
    return func(*args, **kwargs)
  return wrapper


def component(func):
  @functools.wraps(func)
  def wrapper(*args, **kwargs):
    return func(*args, **kwargs)
  return wrapper


def resource(func):
  @functools.wraps(func)
  def wrapper(*args, **kwargs):
    return func(*args, **kwargs)
  return wrapper

# Engine components/resources

class Transform:
  position: Vec3
  scale: Vec2
  skew: Vec2
  pivot: Vec2
  rotation: float

  def __init__(self, position = Vec3(), scale = Vec2(), skew = Vec2(), pivot = Vec2(), rotation = 0.0):
    self.position = position
    self.scale = scale
    self.skew = skew
    self.pivot = pivot
    self.rotation = rotation


class ColorRender:
  visible: bool

  def __init__(self, visible = True):
    self.visible = visible


class FrameConstants:
  delta: float
  frame_rate: float


class Aspect:
  width: float
  height: float
  left: float
  right: float
  top: float
  bottom: float


class Engine:
  spawn: Callable[[List], int]
  despawn: Callable[[int], None]


# Math helpers

def wave(input: float, low: float, high: float) -> float:
  midpoint = (low + high) / 2.0
  amplitude = (high - low) / 2.0
  return midpoint + amplitude * math.sin(input)


def lerp(start: float, end: float, amount: float) -> float:
  return (1 - amount) * start + amount * end
