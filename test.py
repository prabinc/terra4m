import os
import re
import json
from collections import OrderedDict

print("hello world, for real?")
print(os.environ['env_name'])
print(type(os.environ['certs']))
certs = os.environ['certs'].splitlines()
print(certs)
print(type(certs))



