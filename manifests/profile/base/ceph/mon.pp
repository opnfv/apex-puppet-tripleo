# Copyright 2016 Red Hat, Inc.
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
# == Class: tripleo::profile::base::ceph::mon
#
# Ceph Monitor profile for tripleo
#
# === Parameters
#
# [*ceph_pools*]
#   (Optional) Hash of pools to create
#   Example with hiera:
#     tripleo::profile::base::ceph::mon::ceph_pools:
#       mypool:
#         size: 5
#         pg_num: 128
#         pgp_num: 128
#   Defaults to {}
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
class tripleo::profile::base::ceph::mon (
  $ceph_pools = {},
  $step       = Integer(hiera('step')),
) {
  include ::tripleo::profile::base::ceph

  if $step >= 2 {
    include ::ceph::profile::mon
  }

  if $step >= 4 {
    create_resources('ceph::pool', $ceph_pools)
  }
}
