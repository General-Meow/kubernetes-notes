Kubernetes

common commands
- kubectl is the main command used to communicate with a k8 cluster

<resource type>                           - This can be pod, service, node, cronjob, deployments, endpoints, rc, rs

- kubectl cluster-info                    - get info on the cluster
- kubectl config view                     - view kubectl config
- kubectl get <resource type>             - list resources of a type
- kubectl get nodes                       - lists the nodes in the cluster, name, status, roles, age, version
- kubectl get pods -l app=v1              - get pods with label
- kubectl describe <resource type> <id>   - get info on resources

- kubectl create -f <filename.yaml>       - create a new resource defined in the yaml file
- kubectl apply -f <FILENAME.YAML> --record    - create/update the current pod/deployment/service
- kubectl expose <resource type> <id> --port=<PORT> --name=<NAME>   - creates a service for the resource via port specified
- kubectl expose <type/name>              - creates a service to group pods and expose them
- kubectl expose <resource type> <id> --type="NodePort" --port 8080   - expose the resource using nodeport on specified port

- kubectl port-forward <pod> <PORT>       - expose the application on localhosts ip, e.g. forward local requests on that ip
- kubectl port-forward sa-frontend-pod 88:80    - creates a port forward proxy from local port 88 to 80 - used for debugging only - proper way is to create a service
- kubectl proxy                           - create a proxy so that we can access the pods    

- kubectl delete <resource type> <id>     - delete a resource
    - kubectl delete pod <pod_name>
    - kubectl delete deployments <deployment_name>
    - kubectl delete
    - kubectl delete service -l run=<service_name>      - delete the service

- kubectl logs                            - print the logs from a container
                                          - kubectl logs <pod name> <container name> - container name isn't required id=f there is only one container in a pod
- kubectl attach <pod name> -i            - attach to a pod as if you have ssh access
- kubectl run -i -tty busybox --image=busybox --restart=Never --sh      - Create a new pod with the busy box image and log into it. you will then have access to all pods within the cluster - useful for debugging
- kubectl exec <pod id> <COMMAND>         - run a command on a container in a Pod
                                          - e.g. kubectl exec <pod name> <command>
                                          - e.g. kubectl exec <pod name> bash - start a bash shell in the pod container
- kubectl version - get the version of the client as well as the server
- kubectl label pod <pod_name> key=value  - add a key value label to a pod
- kubectl scale deployment <dep_name> --replicas=4
- kubectl scale --replicas=4 -f replicationcontroller.yaml
- kubectl rollout
    - kubectl rollout status <deployment id>                - get the status of a particular rollout of a deployment
    - kubectl rollout history deployment <DEPLOYMENT_NAME>
    - kubectl rollout undo deployment <DEPLOYEMTN_NAME> --to-revision=<VERSION>
- kubectl set image <deployment id> IMAGELABEL=new image:2  - updates the image of the deployment

- kubectl edit <deployment id>          - edit a running deployment settings

### minikube
- minikube dashboard              - start the dashboard
- minikube status                 - get the status of the cluster and kubectl
- minikube ip                     - get the ip of the cluster
- minikube service <name>         - open the service app in the browser
- minikube service <name> --url   - get the url of a service
- minikube ssh                    - open a ssh connection to the cluster

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
  - run will do a nubmer of things, find a suitable node to deploy the app to, schedule the deployment on the node, config the cluster to deploy when needed
- kubectl get deployments: shows all the deployed apps

### Pods
- pods run on a private network and therefore cannot be view from the outside
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
- To apply a rolling deployment, use the command: kubectl apply -f <FILENAME.YAML> --record
- kubectl rollout history deployment <DEPLOYMENT_NAME>
```
deployments "sa-frontend"
REVISION  CHANGE-CAUSE
1         <none>         
2         kubectl.exe apply --filename=sa-frontend-deployment-green.yaml --record=true
```
- kubectl rollout undo deployment sa-frontend --to-revision=1

### Services
- A Service is a grouping of a set of Pods with a policy of accessing them
  - defined using YAML or JSON
  - the set of Pods targeted using a LabelSelector
  - Allows Pods to receive traffic
  - Can be exposed in different ways by using the type option in ServiceSpec
    - ClusterIP: internal ip to the service
    - NodePort: exposes the Pods by using the same IP and Ports for each Pod using NAT, exposes a service on each node with the port
    - LoadBalancer: external loadbalance with ext ip
    - ExternalName: gives a name to the service using a CNAME
- Services can be used with selectors, this will mean no endpoints will be created so you'll need to manually create them
- Services are created using the kubectl expose command
- Service ports can only run on ports between 30000 - 32767



$ kubectl get svc
NAME          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes    ClusterIP   10.96.0.1      <none>        443/TCP        1d
web-service   NodePort    10.110.47.84   <none>        80:31074/TCP   12s

services forward traffic from one port to another. in the case above traffic that hits the port 31074 on that node will be forwarded to port 80 on the defined ClusterIP

### Volumes
- volumes are the ways in which k8s saves state for pods/container - as they are mostly ephemeral
- there are many types of volumes, each will have a different effect on its properties
- emptyDir: essentailly a volume for one pod. when the pod dies, the volume gets deleted
  hostPath: mount a directory on the host within the pod. is persisted even when the pod dies
  gcePersistentDisk: mounts a google cloud engine disk to a pod
  awsElasticBlockStore: aws version of the above
  nfs: mounts a network filesystem to a pod
  iscsi:
  secret: used to pass sensitive information to a pod
  persistentVolumeClaim
- because volumes can be complex and because there are many types, k8s has the PersistentVolume(PV) subsystem.
- to manage it, we use the PersistentVolume API and the persistentVolumeClaim api to consume it
- a claim is essentially a request for some storage, once received the claim is attched to the PV
- the PV then can be used with a pod

### ConfigMaps
- these are configuration key value pairs that can be used by pods
- kubectl create configmap ...
- the configs can be created using literals for files
- to use them in deployment files, you use the valueFrom and configMapKeyRef
- secrets are used to store configs that are sensitive.
- kubectl create secret generic my-secrete --from-literal=password=mypassword <- creates a secrete called my-secrete with the key password and value mypassword
- to use a secret in a pod, you simply have to mount it as a volume

### Labels
- key value pairs that can be applied to objects and nodes
- you can apply multiple and can be duplicated
- used with expressions to get services to apply to specific pods
- also used for pods to run on specific nodes
- use: `kubectl label nodes <NODE_ID> KEY=VALUE`
- use the nodeSelector on the pod/deployment yaml definition

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
