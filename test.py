import os
import ast
import json
from collections import OrderedDict

# print("hello world, for real?")
# print(os.environ['env_name'])
# print(type(os.environ['certs']))
certs_input = os.environ["certs"].splitlines()
# print(certs)
# print(type(certs))
policy_file = {"dev": "policy/dev/policy.json", "prod": "policy/prod/policy.json"}

env_name = os.environ["env_name"]
role = os.environ["role"]


def load_file():
    file_path = policy_file[env_name]
    with open(file_path) as f:
        policy = json.load(f, object_pairs_hook=OrderedDict)
    return policy


def check_cert_format(certs):
    print("entering function")
    for item in certs:
        try:
            cert = ast.literal_eval(item)
        except:
            raise ValueError("Enter a valid cert")
        else:
            if not isinstance(cert, dict):
                raise ValueError("Input a valid cert")


def cert_exists():
    pass


def add_cert(policy_file, certs, role):
    for cert in certs:
        for item in policy_file["roles"]:
            if item["name"] == role:
                item["users"].append(cert)


def print_all_users(policy):
    for item in range(len(policy["roles"])):
        for user in item["users"]:
            print(user)


if __name__ == "__main__":
    check_cert_format(certs_input)
    policy = load_file()
    print_all_users(policy)
    add_cert(policy, certs_to_add, role)
    print_all_users(policy)

