import os
import ast
import json
from collections import OrderedDict

print("hello world, for real?")
print(os.environ['env_name'])
print(type(os.environ['certs']))
certs = os.environ['certs'].splitlines()
print(certs)
print(type(certs))

def check_cert_format(certs):
  print("entering function")
  for item in certs:
    try:
      cert = ast.literal_eval(item)
    except:
      raise ValueError("Enter a valid cert")
    try:
      isinstance(item, dict)
    except:
      print("Please input cert in a valid format.")
      
      
check_cert_format(certs)
    
    



