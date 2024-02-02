Readme
-------

1. install-aks.sh  - Create new Azure AKS infrastructure
2. install-np.sh   - Create AKS node pools for your applications

3. build-charts.sh  - Download helm charts to local folder (Optional). You may use these helm in deploy-base.sh 
4. build-docker.sh  - Docketize your projects.  Use these images in deploy-base.sh and deploy-app.sh

5. deploy-base.sh  - Deploy base software such as database, webservers, queing system.
6. deploy-app.sh   - Deploy your applications

7. overrides.env   - Environment customization or overrides