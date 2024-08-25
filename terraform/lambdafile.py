import os

def handler_name(event, context):
  print("hello")
  print(event)
  print(context)
  print("BLAH is:")
  print(os.environ.get('BLAH'))
  print("KAFKA_HOST is:")
  print(os.environ.get('KAFKA_HOST'))

  return "hello"