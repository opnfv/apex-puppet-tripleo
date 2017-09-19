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
# == Class: tripleo::profile::base::vpp
#
# vpp profile for tripleo
#
# === Parameters
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
class tripleo::profile::base::vpp (
  $step = hiera('step'),
  $vpp_ctlplane_cidr = hiera('vpp_ctlplane_cidr', undef)
) {
  if $step >= 1 {
    include ::fdio

    # Need to use the controller's real IP since we only support noha scenario
    # If this is a ha scenario, we won't configure here.
    $controllers = any2array(split(hiera('controller_node_ips'), ','))
    if !empty($vpp_ctlplane_cidr) and size($controllers) == 1 {
      exec { 'vpp admin - kernel interface config':
        command => "ip link add vpp-admin type veth peer name veth-admin && ip li set dev veth-admin master br-ctlplane && ifconfig veth-admin up",
        path    => ['/bin', '/sbin'],
        unless  => 'ip link show veth-admin | grep br-ctlplane',
        require => Class['fdio'],
      }
      file_line { 'create vpp-admin interface':
        path => '/etc/vpp/vpp-exec',
        line => "create host-interface name vpp-admin",
      } ->
      file_line { 'set vpp-admin interface ip':
        path => '/etc/vpp/vpp-exec',
        line => "set int ip addr host-vpp-admin ${vpp_ctlplane_cidr}",
      } ->
      file_line { 'unshut vpp-admin interface':
        path   => '/etc/vpp/vpp-exec',
        line   => "set interface state host-vpp-admin up",
        notify => Service['vpp'],
      }
    }
  }
}
