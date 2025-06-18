from sdk import *
import colorsys
import random as rand

# This is a sample game file that holds ECS component and system definitions.

rand.seed("python fiasco game seed")


@component
class Star:
  angle: float
  speed: float


@system
def star_mover(query: Query[Transform, Star, Color], consts: FrameConstants, aspect: Aspect):
  for [transform, star, color] in query:
    speed = consts.delta * star.speed
    pos = Vec2(math.cos(star.angle), math.sin(star.angle)) * speed
    transform.position += pos
    transform.rotation -= consts.delta * 2
    update_color(color, consts.delta)

    if transform.position.x > aspect.right:
      transform.position.x = aspect.right
      star.angle = math.pi - star.angle
    elif transform.position.x < aspect.left:
      transform.position.x = aspect.left
      star.angle = math.pi - star.angle
    elif transform.position.y > aspect.top:
      transform.position.y = aspect.top
      star.angle = -star.angle
    elif transform.position.y < aspect.bottom:
      transform.position.y = aspect.bottom
      star.angle = -star.angle


@system_once
def spawner(engine: Engine, aspect: Aspect):    
  for _ in range(100):
    x = rand.randint(int(aspect.left), int(aspect.right))
    y = rand.randint(int(aspect.bottom), int(aspect.top))
    position = Vec3(x, y)

    scale_x = rand.randint(10, 30)
    scale = Vec2(scale_x, scale_x)

    star = Star()
    star.angle = math.radians(rand.randint(0, 360))
    star.speed = rand.randint(100, 1000)

    engine.spawn([
      Transform(position, scale, rotation=math.radians(rand.randint(0, 360)) ),
      ColorRender(),
      Color(rand.random(), rand.random(), rand.random(), .8),
      star,
    ])


def update_color(color: Color, delta: float):
  [h,_,_] = colorsys.rgb_to_hsv(color.r, color.g, color.b)
  [r,g,b] = colorsys.hsv_to_rgb(h + delta, 1, 1)
  color.r = r
  color.g = g
  color.b = b