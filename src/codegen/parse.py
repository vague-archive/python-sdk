import ast

# TODO: in the future, this file will hold the script to parse game files
# and generate the `ecs_module.pyx` file

def parse(code: str):
  module = ast.parse(code)

  for node in ast.walk(module):
    if isinstance(node, ast.FunctionDef):
        has_decorators = bool(node.decorator_list)
        print("Function name:", node.name, has_decorators)
