# Copyright 2017 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: tripleo::profile::base::neutron::agents::vpp
#
# Neutron VPP Agent profile for tripleo
#
# === Parameters
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
# [*etcd_host*]
#   (Optional) etcd server VIP.
#   Defaults to hiera('etcd_vip')
#
# [*etcd_port*]
#   (Optional) etcd server listening port.
#   Defaults to 2379
#
# [*physnet_mapping*]
#   (Optional) physnet mapping, example: 'datacentre:eth1'. Note that the
#   interface specified here is a kernel interface name that is bound to
#   VPP.
#   Defaults to []
#
# [*type_drivers*]
#   (optional) List of network type driver entrypoints to be loaded
#   Could be an array that can contain flat, vlan or vxlan
#   Defaults to hiera('neutron::plugins::ml2::type_drivers', undef)
#
class tripleo::profile::base::neutron::agents::vpp(
  $step            = Integer(hiera('step')),
  $etcd_host       = hiera('etcd_vip'),
  $etcd_port       = 2379,
  $physnet_mapping = [],
  $type_drivers    = hiera('neutron::plugins::ml2::type_drivers', undef),
) {
  if empty($etcd_host) {
    fail('etcd_vip not set in hieradata')
  }

  if $step >= 4 {
    if $::hostname in hiera('controller_node_names') {
      $service_plugins = hiera('neutron::service_plugins')
    } else {
      $service_plugins = undef
    }
    class { '::neutron::agents::ml2::vpp':
      etcd_host       => $etcd_host,
      etcd_port       => $etcd_port,
      physnets        => vpp_physnet_mapping($physnet_mapping),
      type_drivers    => $type_drivers,
      service_plugins => $service_plugins,
    }
  }
}
