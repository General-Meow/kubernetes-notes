
start up the k3d cluster to expose services
`k3d cluster create home-dashboard-cluster --api-port 6550 -p "8081:80@loadbalancer" --agents 2`

create the services and deployments of 2 instances of nginx 
`helmfile apply`

create a configmap of the entire nginx custom directory so that it can serve the second nginx instance
`kubectl create configmap custom-index --from-file=./nginx-custom-values/nginx-public-folder`

this then gets referred to in the values file for the second nginx instance
`staticSiteConfigmap: "custom-index"`

create 2 ingress' one to map to root (/) goes to one nginx release
then the other /custom to the other nginx instance

`kubectl apply -f ingress.yaml`
`kubectl apply -f ingress-nginx-custom.yaml`

navigate to localhost:8081
also navigate to localhost:8081/custom