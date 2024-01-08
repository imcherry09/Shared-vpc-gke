# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

apiVersion: v1
kind: Namespace
metadata:
  name: ${k8s_ns}
---  
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-deployment-manager
  namespace: ${k8s_ns}
rules:
- apiGroups: 
    - ''
    - 'extensions'
    - 'apps'
  resources: 
    - 'namespaces'
    - 'serviceaccounts'
    - 'deployments'
  verbs: 
    - 'get'
    - 'list'
    - 'watch'
    - 'create'
    - 'update'
    - 'patch'
    - 'delete'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-deployment-manager
  namespace: ${k8s_ns}
subjects:
- kind: User
  name: ${google_sa}
roleRef:
  kind: Role
  name: app-deployment-manager
  apiGroup: rbac.authorization.k8s.io
