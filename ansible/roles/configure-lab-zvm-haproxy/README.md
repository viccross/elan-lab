configure-lab-zvm-haproxy
=========================

Some of the ELAN functions rely on being able to talk to z/VM.
Due to the setup of the three ELAN hosts in the lab, direct connectivity to z/VM via the private network is not possible.
This leads to either functions being unavailable, or nasty hacks in the lab config where z/VM is referred to via its front-end IP rather than private.

This role configures a separate HAProxy instance on the dev ELANs to forward requests to the z/VM private IP address.
The z/VM private IP address is configured as a secondary IP on the internal interface of the ELAN (since other hosts such as ICIC may need it).
Services configured in the HAProxy instance are:
- LDAP
- SMAPI
- PerfKit web interface
- TN3270

Requirements
------------

None

Role Variables
--------------

None AFAIK (other than standard inventory variables).

Dependencies
------------

None.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: configure-lab-zvm-haproxy, x: 42 }

License
-------

BSD

Author Information
------------------

Vic Cross <viccross@au1.ibm.com>
