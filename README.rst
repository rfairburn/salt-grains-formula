grains
=======

Salt formula to manage minion custom grains from the master.

.. note::

    This formula outlines a basic way to manage minion grains centrally from the master.  
    Currently it is desgined to handle 'roles', 'categories', and 'sudoers.included'
    (a custom grain I use with my sudoers formula)
    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.



Available states
================

``grains``
----------
    Setup grains assigned to the minion from the grains pillar.  Assigns default category if the system is not defined.

Implementation Example
================

.. note::
    
    Ideally the roles assigned through these grains would be used to apply states to a minion through the following in the top.sls:

.. code:: jinja2

    {% if 'roles' in grains %}
      {% for role in salt['grains.get']('roles', []) %}
       - {{ role }}
      {% endfor %}
    {% endif %}
    
Example Pillar
================

.. note::

    If you are just using this formula for role management, you can exclude anything about sudoers_included below.  Check `Devop Ninja <http://devop.ninja>`_ soon for an article on the sudoers portion.


.. code:: yaml

    grains:
      categories:
    # Used if a system is not indicated below
        default:
          categories:
            - nrpe
            - sudoers
    # Service category designations
        dnsmasq:
          roles:
            - dnsmasq
            - hosts
        jenkins_deploy_target:
          sudoers.included:
            - jenkins
          categories:
            - sudoers
        nrpe:
          roles:
            - nagios.nrpe
            - files.nagios_plugins
        sudoers:
          roles:
            - sudoers
            - sudoers.included
            - files.sudoers_cleanup
          sudoers.included:
            - cloud-init
    # Environment category designations
    # Used to add designations and properly manage sudoers
    # Potentially used to manage unique 'roles' per environment
    # (dev,stage,test,uat,prod,support, etc)
    #
    # Nonprod designations
        non_prod_server:
          sudoers.included:
            - corp-non-prod
          categories:
            - sudoers
        demo_server:
          categories:
            - non_prod_server
        stage_server:
          categories:
            - non_prod_server
        test_server:
          categories:
            - non_prod_server
        uat_server:
          categories:
            - non_prod_server
    # Prod designations
        prod_server:
          sudoers.included:
            - corp-prod
          categories:
            - sudoers
        support_server:
          categories:
            - prod_server
      systems:
    # Minion system. The line below should match grains['id']
        salt-minion:
          roles:
            - nagios.server
          categories:
            - default
            - prod_server
            - jenkins_deploy_target
    # Another minion system example
        salt-master:
          roles:
            - files.salt_master_files
          categories:
            - default
            - support_server
