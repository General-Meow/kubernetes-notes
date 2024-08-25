# Kubernetes

### common commands

```
- kubectl is the main command used to communicate with a k8 cluster

<resource type>                                 - This can be pod, service, node, cronjob, deployments, endpoints, ingress, rc (resource controller), rs (resource set)
YAML files are the manefest files that describe the objects created in k8s

- kubectl cluster-info                          - get info on the cluster
- kubectl config view                           - view kubectl config
- kubectl get <resource type>                   - list resources of a type
- kubectl get nodes                             - lists the nodes in the cluster, name, status, roles, age, version
- kubectl get pods -l app=v1                    - get pods with label key app and value v1
- kubectl describe <resource type> <id>         - get info on resources

- kubectl create -f <filename.yaml>             - create a new resource defined in the yaml manifest file
- kubectl apply -f <FILENAME.YAML> --record     - create/update the current pod/deployment/service
- kubectl expose <resource type> <id> --port=<PORT> --name=<NAME>     - creates a service for the resource via port specified
- kubectl expose <type/name>                    - creates a service to group pods and expose them
- kubectl expose <resource type> <id> --type="NodePort" --port 8080   - expose the resource using nodeport on specified port

- kubectl port-forward <pod> <PORT>             - expose the application on localhosts ip, e.g. forward local requests on that ip
- kubectl port-forward sa-frontend-pod 88:80    - creates a port forward proxy from local port 88 to 80 - used for debugging only - proper way is to create a service
- kubectl proxy                                 - create a proxy so that we can access the pods    

- kubectl delete <resource type> <id>           - delete a resource
    - kubectl delete pod <pod_name>
    - kubectl delete deployments <deployment_name>
    - kubectl delete
    - kubectl delete service -l run=<service_name>      - delete the service

- kubectl logs                                  - print the logs from a container
                                                - kubectl logs <pod name> <container name> - container name isn't required id=f there is only one container in a pod
- kubectl attach <pod name> -i                  - attach to a pod as if you have ssh access
- kubectl run -i -tty busybox --image=busybox --restart=Never --sh      - Create a new pod with the busy box image and log into it. you will then have access to all pods within the cluster - useful for debugging
- kubectl exec <pod id> <COMMAND>               - run a command on a container in a Pod
                                                - e.g. kubectl exec <pod name> <command>
                                                - e.g. kubectl exec <pod name> bash - start a bash shell in the pod container
- kubectl version - get the version of the client as well as the server
- kubectl label pod <pod_name> key=value        - add a key value label to a pod
- kubectl scale deployment <dep_name> --replicas=4
- kubectl scale --replicas=4 -f replicationcontroller.yaml
- kubectl rollout
    - kubectl rollout restart deployment <deployment id>, redeploy pods, is pull always is on, it'll get the latest image
    - kubectl rollout status <deployment id>                - get the status of a particular rollout of a deployment
    - kubectl rollout history deployment <DEPLOYMENT_NAME>
    - kubectl rollout undo deployment <DEPLOYEMTN_NAME> --to-revision=<VERSION>
- kubectl set image <deployment id> IMAGELABEL=new image:2  - updates the image of the deployment

- kubectl edit <deployment id>                - edit a running deployment settings
- kubectl get events --sort-by=.metadata.creationTimestamp      - get events to debug
```

### Debugging

```
- kubectl run -it --rm --restart=Never busybox --image=busybox sh   - run a pod with a command prompt
- kubectl exec <POD-NAME> -c <CONTAINER-NAME> -- <COMMAND>          - connect to an existing pod with a command prompt
- kubectl config get-contexts                                       - look at the configuration of kubectl and see what your current context is
- kubectl get secret                                                - list all secrets in the default namespace
- kubectl get secret <SECRET NAME>  -o yaml                         - list out all the stored key value pairs in the secret
- echo '<ENCODED VALUE>' | base64 --decode                          - decord the encoded value from the secret
```
### minikube

```
- minikube dashboard              - start the dashboard
- minikube status                 - get the status of the cluster and kubectl
- minikube ip                     - get the ip of the cluster
- minikube service <name>         - open the service app in the browser
- minikube service <name> --url   - get the url of a service
- minikube ssh                    - open a ssh connection to the cluster
```

### Cluster setup

on master as root:

```
kubeadm init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

then on master as normal user:
deploy the network pod: https://kubernetes.io/docs/concepts/cluster-administration/addons/
kubectl apply -f [podnetwork].yaml e.g. kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

on slave:
swapoff -a
kubeadm join 192.168.1.85:6443 --token a52hlv.s47svvp70d6p7y5q \
--discovery-token-ca-cert-hash sha256:92c9888ecdbc7b0815459e1aae4d4645d53227a1f8ada2c736b0ee3f3c3c6c30

### Helm

```
- https://artifacthub.io/                 - is the public repo
- helm init                               - install helm (Tiller) onto a cluster (k3s/k3d comes with helm installed ootb) 
- helm reset                              - remove helm (Tiller) from a cluster
- helm create <CHART NAME>                - create a new helm chart
- helm install <NAME> <URL>               - install a helm chart onto the cluster from the URL and give it a local name
- helm search hub <PACKAGE NAME> -o json  - search for a helm package in the standard repo called hub, use the url to navigate to and get install instructions from there
- helm search <REPO> <PACKAGE NAME>       - search for a helm package in the provided repo
- helm list                               - list installed helm charts
- helm delete <PACKAGE NAME>
- helm history                            - get history of releases, could be used for rollbacks
- helm upgrade/rollback
  - helm upgrade --set image.tag=<VERSION> <RELEASE/CHART DEPLOYMENT NAME> <CHART_DIR>
  - helm upgrade --set image.tag=0.0.3 bumpty_fly .
  - helm rollback <DEPLOYMENT NAME> <HISTORY VERSION>
  - helm rollback bumpty_fly 1
- helm dependency update                  - uses the requirements.yaml in the root directory to automatically download dependencies
- helm package <CHART>                    - package and version the chart
- helm ... push ....
- helm repo list                          - lists the installed helm repos
- helm repo add/remove <NAME> <URL>       - add or remove a repo
- helm repo update                        - update the cached repo info
-
```
### Helmfile

- helmfile

### Replication controller vs Replica sets vs Deployments

- All 3 of these give you the ability to replicate the same pod many times, this gives you scalability, load balancing, reliability (and auto healing)
- The replication controller is the original form of replication which was then replaced with replica sets
- Just like Replication controllers, Replica sets give the same features but also allow you to select/filter pods/images using logic/expressions e.g. !=, in [x, x, x]
- You also lose a feature with replica sets, and thats the rolling-update command and thats because the replica sets are supposed
to be the backend to deployments
- Deployments replace Replication Controllers, they use replica sets and also has the rollout and roll back features, pause resume rollout (only have a percentage of updated pods)
- the resource type is rc/rs/deployment
- Deployments can contain replica sets, replica sets can contain many pods

### Deployments

- kubernetes deployment configuration is used to define how to deploy (create/update) applications on a cluster
- k8 deployment controllers monitors the apps (instances) that have been deployed
  - if a node hosting that instance dies, the deployment controller replaces it (self healing)
- You use `kubectl create -f ...` deployment configs
- typical format to use kubectl is kubectl <action> <resource>
- to get help, use kubectl to list the options and kubectl <action> --help
- the kubectl run command creates a new deployment, you need to provide it with a name and image location, port can be added too
  - you will have to give the full url of the image if its hosted on dockerhub
  - kubectl run kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1 --port=8080
  - run will do a number of things, find a suitable node to deploy the app to, schedule the deployment on the node, config the cluster to deploy when needed
- `kubectl get deployments`: shows all the deployed apps

### Pods

- pods run on a private network and therefore cannot be viewed from the outside
- pods can see other pods
- you have to use kubectl to route traffic from the outside to the pods
- use kubectl proxy to create the proxy that will allow to communicate via it network wide
- Pods is an abstraction of a group of one or many containers and shared resources for them
  - storage as volumes
  - networking
- Pods usually group applications that are typically related or coupled in a way
- Pods are atomic units
- Pods are created when you create a deployment
- A Pod is tied to a node
- A Pod has a unique IP address
- Containers in a Pod share the same IP address, Volume, Port space

- Nodes can have multiple Pods
- Each node runs
  - Kubelet - agent for comms with the master node and manages Pods
  - container runtime to run the containers

### Rollbacks

- If you do rolling deployments, you can record them and then rollback if you find any issues
- To apply a rolling deployment, use the command: `kubectl apply -f <FILENAME.YAML> --record`
- `kubectl rollout history deployment <DEPLOYMENT_NAME>` returns the history of a rollout deployment for a certain deployment

```
deployments "sa-frontend"
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl.exe apply --filename=sa-frontend-deployment-green.yaml --record=true
```

- `kubectl rollout undo deployment sa-frontend --to-revision=1` reverts to a recorded deployment, in this case its to revision 1

### Services

- A Service is a grouping of a set of Pods with a policy of accessing them
  - defined using YAML or JSON
  - the set of Pods targeted using a LabelSelector
  - Allows Pods to receive traffic (from outside the cluster?)
  - Can be exposed in different ways by using the `type` property in the spec section
    - ClusterIP: internal ip to the service, with a specified port. The default if not specified
    - NodePort: exposes the Pods by using the same IP and Ports for each Pod using NAT, exposes a service on each node with the port
    - LoadBalancer: external loadbalance with ext ip
    - ExternalName: gives a name to the service using a CNAME
  - Usually `ClusterIP` is used in combination with an `Ingress` and a `loadbalancer` to expose the service
- Services can be used with selectors, this will mean no endpoints will be created so you'll need to manually create them
- Services are created using the `kubectl expose` command
- Service ports can only run on ports between 30000 - 32767

```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ClusterIP
  selector:
    app.kubernetes.io/name: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```

```
$ kubectl get svc
NAME          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes    ClusterIP   10.96.0.1      <none>        443/TCP        1d
web-service   NodePort    10.110.47.84   <none>        80:31074/TCP   12s
```

services forward traffic from one port to another. in the case above traffic that hits the port 31074 on that node will be forwarded to port 80 on the defined ClusterIP

### Volumes

- volumes are the ways in which k8s saves state for pods/container - as they are mostly ephemeral
- there are many types of volumes, each will have a different effect on its properties
- emptyDir: essentially a volume for one pod. when the pod dies, the volume gets deleted
  hostPath: mount a directory on the host within the pod. is persisted even when the pod dies
  gcePersistentDisk: mounts a google cloud engine disk to a pod
  awsElasticBlockStore: aws version of the above
  nfs: mounts a network filesystem to a pod
  iscsi:
  secret: used to pass sensitive information to a pod
  persistentVolumeClaim
- because volumes can be complex and because there are many types, k8s has the PersistentVolume(PV) subsystem.
- We use the PersistentVolume API to manage it (create/delete) and the persistentVolumeClaim api to consume it
- a claim is essentially a request for some storage, once received, the claim is attached to the PV
- the PV then can be used with a pod
- To enable PV on AWS, you first need to provision an EBS (Elastic block store)
  - `aws ec2 create-volume --size 10 --region us-east-1 --availability-zone us-east-1a --volume-type gp2`
  - this will return json with meta data. The VolumeID field is what your interested in

```POD example
apiVersion: ..
type: pod
...
spec:
  containers:
  - name: ...
    volumeMounts:
    - mountPath: /myLocalDirMountPath
      name: myVolume
  volumes:
    - name: myVolume
      awsElasticBlockStore
        volumeId: <THE VOLUME ID FROM THE PROVISIONING>
```

- The provisioning of the EBS can be done automatically with k8 plugins
- The AWS plugin allows you to create the volume and make it available by using a new kind called `StorageClass`
- Example of an auto provisioned store

```
apiVersion:
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  zone: us-east-1
```

- You can then use the created objects to create Claims
- Example of a claim on the StorageClass

```
apiVersion: v1
kind: persistentVolumeClaim
metadata:
  name: myClaim
  annotations:
    volume.beta.kubernetes.io/storage-class: "standard"     #this is the metadata name from the StorageClass above
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storageL 8Gi
```

- Then a pod using the claim

```
spec:
  containers:
  - name: ...
    volumenMounts:
    - mountPath: /myLocalDirMountPath
      name: myVolume
  volumes:
    - name: myVolume
      claimName: myClaim
```

### ConfigMaps & secrets

- these are configuration key value pairs that can be used by pods, best used for properties that are not confidential
- config maps can be used in env vars, container command line args and volumes
- the configs can be created using literals or full files like app config files eg apache.conf
- to use them in deployment files, you use them as volumes or text from valueFrom and configMapKeyRef
- To create a config file to be used as a config map, just create a file with key value pairs. e.g.
  - name=paul
    dbName=tcs
    app.name=my service discovery app
- `kubectl create configmap <NAME OF CONFIG MAP> --from-file=<FILENAME.properties>`
- usage in a POD spec using volume mount

```
spec:
  containers:
  - name: myPod
    ...
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
    volumes:
    - name: config-volume
      configMap:
        name: <NAME OF CONFIG MAP>
```

- usage as text in a pod

```
spec:
  containers:
  - name: myPod
    ...
    env:
    - name: DRIVER    # name of the env var
      valueFrom:
        configMapKeyRef:
        name: <NAME OF CONFIG MAP>
        key: <NAME OF KEY>
```

- secrets are used to store configs that are sensitive.
- `kubectl create secret generic my-secret --from-literal=password=mypassword` : creates a secrete called my-secret with the key password and value mypassword
- to use a secret in a pod, you simply have to mount it as a volume

### Labels

- key value pairs that can be applied to objects and nodes
- you can apply multiple and can be duplicated
- used with expressions to get services to apply to specific pods
- you can view a nodes label by using describe: `kubectl describe node <NODE ID>`
- also used for pods to run on specific nodes
- use: `kubectl label nodes <NODE_ID> KEY=VALUE`
- use the nodeSelector on the pod/deployment yaml definition
- there are some OOTB labels applied, here are the keys:
  - kubernetes.io/hostname
  - failure-domain.beta.kubernetes.io/zone
  - failure-domain.beta.kubernetes.io/region
  - beta.kubernetes.io/instance-type
  - beta.kubernetes.io/os
  - beta.kubernetes.io/arch

### node affinity / anti affinity / interpod affinity / interpod anti affinity / Tolerations
- more powerful than nodeSelector
- rules are not hard requirements, meaning that the pod/deployment can still be deployed even
  if there are no nodes that meet its requirement
- rules can also take into account other pods and not just nodes
  - eg no 2 pods can be on the same node
- only takes into account when scheduling
  - new nodes added to a cluster with a better affinity match will not trigger a pod to be redeployed
  - if you want that, you need to manually delete that pod
- there are 2 types of node affinity
  - requiredDuringSchedulingIgnoredDuringExecution : hard requirement
  - preferredDuringSchedulingIgoredDuringExecution : will try to enforce but cannot guarantee
```
...
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: env
            operator: in
            values:
            - dev
      preferredDuringSchedulingIgoredDuringExecution:
      - weight: 1        # the higher the weighting the more important/points is given as a rule
        preference:
          matchExpressions:
          - key: team
            operator: in
            values:
            - engineering-project-1
```
- interpod affinity is just like node affinity but is based on current running Pods
- works in only one namespace at a time, if no namespace is provided it'll run in the default namespace
- 2 types
  - requiredDuringSchedulingIgnoredDuringExecution
  - preferredDuringSchedulingIgoredDuringExecution
- a good reason for interpod affinity is co location of pods (having pods on the same node, rather than defining the node itself)
- topologyKey is the settings to use. (this can get complicated)
  - this takes in a key of a label of that node that the required/prefered matching critera matches on and finds the value
    then it uses that value as a possible prefered matching critera for the new pod being deployed.
- anti pod affinity is the opposite where a new schedule pod will NOT be deployed if it matches the criteria
- operators that are supported
  - In, NotIn
  - Exists, DoesNotExist
- Tolerations apply to pods
- Taints apply to a node
- To taint a node use command `kubectl taint nodes <NODE ID> <KEY>=<VALUE>`
- To remove a taint on a node, use a minus char after the key  `kubectl taint nodes <NODE ID> <KEY>-`
- Nodes that are tainted will not have pods scheduled unless the pods have been marked with a matching tolerations
```pod/deployment
...
tolerations:
- key:
  operator: Equal
  value: ""
  effect: "NoSchedule"
```
- just like affinity etc, taints can be hard requirements or a preference (soft)
  - this is done with effect:
    - "NoSchedule" - hard
    - "PreferNoSchedule" - soft
- applying a taint to a node will not evict current running pods unless "NoExecute: evict" is used
  - if using this you can specify how long pods can be running before its evicted
  - use property "tolerationSeconds"
- Typically use of taints
  - master node (you dont want pods running on that)
  - nodes for teams or indiviuals
  - specialised hardware nodes
  - nodes that have problems



### Health checks
- used to detect and resolve problems
- if there are problems, then the RC and kill the pod and start a new one to help with avaiablility and ressiliance
- 2 ways k8 does this
  - periodically run a command within the pod
  - have checks via a http endpoint
- use the `livenessProbes` property on the container spec to define if a pod is healthy/running
  - if this fail then k8 will kill it and start another
- use the `readinessProbes` property on the container spec to define if the container is ready to serve requests
  - if this fails, k8 will remove the pod's ip from the service object so it cannot receive requests
- both can be used in conjunction

### Web ui / Dashboard
- can be accessed via http://<k8 MASTER NODE IP>/ui
- its installed with `kubectl create -f http://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml`
- kubectl config view - for the password
- for minikube you can use `minikube dashboard`


### Service discovery / DNS
- DNS comes out the box since k8 1.3
- Addons can be viewed in /etc/kubernetes/addons on the master node
- must be used with Service objects
- containers within a pod do not need to use services/dns as they can comms with each other using localhost
- It works by adding a line to the containers /etc/resolv.conf file to point to the DNS pod in the kube-system namespace
  - this means that all comes will be routed via the k8 DNS pod
- All service Object names will be reconised by the DNS Pod so you can refer to each service in each deployments env variable

### Ingress
- Used to allow inbound http requests into the private clustered network
- alternative to the cloud providers load balancer/nodePort features
- used to easily expose pods and services
- There are ingress controllers which are like loadbalancers within k8
- Default ingress controllers are available but you can also write your own
  - behind the scenes, the default ingress controller uses nginx
- Using Ingress you define how requests are routed
- To get it working, you need to define an ingress object with the routing rules as
well as the actual ingress pod to do the work
- Example of an ingress yaml object containing the rules

```YAML
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: helloworld-rules
spec:
  rules:
  - host: helloworld-v1.example.com       #the request is looking for this host
    http:
      paths:
      - path: /                           # with the path
        backend:
          serviceName: helloworld-v1
          servicePort: 80
  - host: helloword-v2.example.com
    http:
      paths:
      - path: /                           # with the path
        backend:
          serviceName: helloworld-v2
          servicePort: 80
```

- Example of an ingress deployment

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-ingress-controller
  labels:
    k8s-app: nginx-ingress-lb
spec:
  replicas: 1
  selector:
    k8s-apps: nginx-ingress-lb
  template:
    metadata:
      labels:
        k8-app: nginx-ingress-lb
        name: nginx-ingress-lb
    spec:
      terminationGracePeriodSeconds: 60
      containers:
      - image: gcr.io/google_containers/nginx-ingress-controller:0.8.3 # there are other implementations too, look them up at the docker hub
        name: nginx-ingress-lb
        imagePullPolicy: Always
        readinessProbe:
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
        env:
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: dsdfdsf.dsfd
        ports:
        - containerPort: 80
          hostPost: 80
        - containerPort: 443
          hostPort: 443
```


### Pod Presets
- These are effectively settings/env vars that you want to share with pods.
- Think of them as common config
- To use them, you need to ensure that its enabled as its currently in alpha (check documentation on it)
```
apiVersion: settings.k8s.io/v1alpha1
kind: PodPreset
metadata:
  name: allow-database
spec:
  selector:
    matchLabels:
      role: frontend
  env:
    - name: DB_PORT
      value: "6379"
  volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
    - name: cache-volume
      emptyDir: {}
```


### DaemonSets
- Used to ensure every node in the cluster is running a defined pod
- typically used to export metrics, show health, agent based stuff etc
- new nodes that are added will automatically have the defined pod deployed
- nodes that are removed will not have the pods rescheduled
```
apiVersion: extensions/v1beta1
kind: DeamonSet
metadata:
...
spec:
...
```

### StatefulSets (PetSets)
- Used to be called petsets
- used for stateful applications where they need a stable hostname
- podnames will be sticky, with the format <PODNAME>-<NUMBER> where the number starts at Zero
- pod names will also be sticky in that pods that are rescheduled will have the same name
- volumes will also be sticky with stateful sets and they will also stick around after the pod gets deleted
- allows for ordered startups/shutdowns in that they start up from index zero and shutdown from n-1
```
apiVersion: apps/v1
kind: StatefulSet
metadata:
...
spec:
...
```

### Auto scaling
- can be done on deployments, replica sets and replica controller pods
- from k8 1.3 cpu based scalling is possible ootb
- alpha support for custom app based metrics when restarted with ENABLE_CUSTOM_METRICS
- monitoring tools must be installed for scalling to work e.g. heapster
- the default time for querying the load is 30 sections, can be changed with --horizontal-pod-autoscaler-sync-period
- the measurement of cpu usage is in millicores. 200m (millicores is 20% of cpu usage on a single core)
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
spec:
  template:
    spec:
      containers:
      - name: hpa-example
      resources:
        requests:
          cpu: 200m
```

```
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
spec:
  scaleTargetRef:
    apiVersion: extension/v1beta1
    kind: Deployment
    name: hpa-example
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50
```


### Helm
- Much like how applications on ubuntu (apt) - its the package manager for applications on k8s
- It's the recommended why to install your own applications on k8
- To use helm, it needs to be installed, if you have RBAC installed, a service (user) account needs to be created first
  - installing helm will also install Tiller
- A helm chart is the packing structure for a helm managed application
  - it contains a group of files that describes a number of k8 resources (services, deployments etc)
  - it can also contain dependencies - other applications that the chart depends on
  - it contains templates for easy replacement of values
- To create a helm chart, simply use the command `helm create <NAME>`
  - this will create a directory of that name
  - a Chart.yml and values.yaml file
  - also a templates directory with service.yaml and deployment.yaml
  - charts directory containing any charts of your own charts dependencies

```
myChart /
  Chart.yaml    // information about this chanrt
  values.yaml   // the default values (config) for this chart
  charts/       // folder containing this charts dependencies
  templates/    // for the templates that the values file will populate
```

- To install this template you would run `helm install myChart`
- the `values.yaml` file is the default values file thats used to populate the template file. If you don't specify a values file in the `install` command it will use this file
- If you want to override some values for example the dev env, you write your own `values-dev.yaml` file, define the properties you want to override and run install with the `--values=values-dev.yaml` this is apply the default file the apply your overrides
- `helm install --values=values.yaml myChart`
- If you ever want to just override without another values file, you can use the `--set` flag e.g. `helm install --set port=8081 myChart`
- dependencies are defined in the requirements.yaml file in the root directory
```requirements.yaml
dependencies:
- name: mariadb
  version: 4.x.x
  repository: https://kubernetes-charts.storage.googleapis.com
  condition: mariadb.enabled
  tags:
    - node-app-database
```

- You can also do release management with helm, in Helm 2, you'd have Tiller installed in the k8s cluster, in this mode, the helm cli will send the helm chart files to tiller to install (tiller also stores the chart files)
- You can then do `helm install myChart` then `helm upgrade myChart` and it will send the new version of the chart to tiller and will install it (keeping both)
- `helm rollback myChart` will rollback to the last version
- Tiller however has too much permissions by creating, updating removing things so its a security issue
- So now Tiller has been removed from Helm 3 and therefore has no more release management

### Helmfile
- Helmfile just like Helm uses templating but with `Go Templaates` this gives additional functions within your templates
- Go templates have an extension `xxx.yaml.gotmpl`
- You can use environment variables in most properties in the file e.g. `name`, `namespace`, `value`, `values` and `url` can contain templates
- e.g.

```yaml
repositories:
  - name: blah repo
-   url: https://{{ requiredENV "TOKEN" }}}
```

- or

```yaml
releases:
  - name: {{ requiredEnv "ENV" }}-values.yaml
```

- The main configuration file is called `helmfile.yaml`
- It should contain the `release` root property with `name`, `namespace` and `chart` with optional `set` `name` `value`
- You may need the `repository` root node too with `name` and `url` child nodes
