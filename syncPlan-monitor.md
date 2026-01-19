We are building an ansible job that will run on AAP.It uses the redhat.satellite collection.We need the job to monitor sync plan settings for every organization(with an opt out list setting controlled by vars). We need the interval setting to be no more frequent than weekly.
We want that setting to always be weekly.

This is the direct documentation for the module that we have identified as most likely to facilitate this job:
https://redhatsatellite.github.io/satellite-ansible-collection/3.6.0/plugins/sync_plan_module.html#ansible-collections-redhat-satellite-sync-plan-module

I assume we would need to use the Satellite API or the organization modules in the redhat.satellite collection to get the list of all organizations on the Satellite. That list would then be used in the sync plan module as a variable. This is the direct documentation for the two most likely useful modules in the collection:
redhat.satellite.organization module: https://redhatsatellite.github.io/satellite-ansible-collection/3.6.0/plugins/organization_module.html#ansible-collections-redhat-satellite-organization-module
redhat.satellite.organization_info module: https://redhatsatellite.github.io/satellite-ansible-collection/3.6.0/plugins/organization_info_module.html#ansible-collections-redhat-satellite-organization-info-module

We use a group vars structure. This is an example of our structure and style:
satellite_fqdn: "satellite1.com"
satellite_shortname: "satellite1"
satellite_server_url: "https://{{ satellite_fqdn }}"
satellite_setup_username: "{{ app_username }}"  # Default admin user - From AAP credential
satellite_initial_admin_password: "{{ app_password }}"  # From AAP credential
# Organization and Location
satellite_org: "EO_ITRA"  # Organization name for installation
satellite_location: "default_location"  # Location for installation

An example of how we would use the vars in the module:

- name: "Create or update weekly RHEL sync plan"
  redhat.satellite.sync_plan:
    username: "{{ satellite_setup_username }}"
    password: "{{ satellite_initial_admin_password }}"
    server_url: "{{ satellite_fqdn }}"
    name: "Weekly RHEL Sync"
    organization: "Default Organization"
    interval: "weekly"
    enabled: false
    sync_date: "2017-01-01 00:00:00 UTC"
    state: present

To sum up, we need to get the list of organizations. Use that list to check every organizations sync plans. We want to control the sync plan interval only. We don't want to make any other changes to the sync plans. JUST the interval. The correct interval is weekly.
If possible, we would like a very simple report emailed with a status if an organization had any sync plans that needed to be corrected to the weekly interval. We should list the organization that needed to be corrected.


 