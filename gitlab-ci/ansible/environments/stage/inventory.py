#!/usr/bin/python3

from subprocess import Popen, PIPE


def terraform_out(external_ip):
    cmd = "cd $TERRAFORM_STAGE && terraform output " + external_ip
    proc = Popen(cmd, shell = True, stdout=PIPE, stderr=PIPE)
    proc.wait()    # дождаться выполнения
    res = proc.communicate()  # получить tuple('stdout', 'stderr')
    if proc.returncode:
        return (res[1].decode())
    return (res[0].decode().strip())

gitlab_external_ip = terraform_out("gitlab_external_ip")


to_json = '''
{
    "_meta": {
        "hostvars": {
            "gitlabserver": {
                
                "ansible_ssh_host": "''' +  gitlab_external_ip + '''",
            }
        }
    },
    "all": {
        "children": [
            "gitlab",
        ]
    },
    "gitlab": {
        "hosts": [
            "gitlabserver"
        ]
    },
}
'''

print (to_json)
