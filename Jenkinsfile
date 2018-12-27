node {
  stage('Get code from SCM') {
    checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/pktanksali/kubernetes-on-aws.git']]]
  }
  stage('Create Amazon EKS Cluster') {
    sh "cd \${WORKSPACE}/terraform; terraform init -var \"access_key=\${ACCESS_KEY}\" -var \"secret_key=\${SECRET_KEY}\" -var \"cluster-name=\${CLUSTER_NAME}\"; terraform apply -input=false -auto-approve -var \"access_key=\${ACCESS_KEY}\" -var \"secret_key=\${SECRET_KEY}\" -var \"cluster-name=\${CLUSTER_NAME}\""   
  }
  stage('Join Worker Nodes') {
    sh 'mkdir ${WORKSPACE}/.kube'
    sh "cd \${WORKSPACE}/terraform; terraform output kubeconfig >> \${WORKSPACE}/.kube/config-\${CLUSTER_NAME}"
    env.KUBECONFIG = "\${WORKSPACE}/.kube/config-\${CLUSTER_NAME}"
    sh 'kubectl --kubeconfig=${WORKSPACE}/.kube/config-${CLUSTER_NAME} get svc'
    sh "cd \${WORKSPACE}/terraform; terraform output config_map_aws_auth >> \${WORKSPACE}/config_map_aws_auth.yaml"
    sh "kubectl --kubeconfig=\${WORKSPACE}/.kube/config-\${CLUSTER_NAME} apply -f \${WORKSPACE}/config_map_aws_auth.yaml"
    sh "sleep 60; kubectl --kubeconfig=\${WORKSPACE}/.kube/config-\${CLUSTER_NAME} get nodes"
  }
  stage('Deploy Application on EKS') {
    sh 'kubectl --kubeconfig=${WORKSPACE}/.kube/config-${CLUSTER_NAME} apply -f deployments.yaml'
    sh 'sleep 60; kubectl --kubeconfig=${WORKSPACE}/.kube/config-${CLUSTER_NAME} get pods -o wide'
    sh 'kubectl --kubeconfig=${WORKSPACE}/.kube/config-${CLUSTER_NAME} apply -f services.yaml'
    sh 'sleep 15; kubectl --kubeconfig=${WORKSPACE}/.kube/config-${CLUSTER_NAME} get services -o wide'
  }
  stage('Testing the Application') {
    input('QA Approval...')
  } 
  stage('Cleanup') {
    sh "cd \${WORKSPACE}/terraform; terraform destroy -auto-approve -var \"access_key=\${ACCESS_KEY}\" -var \"secret_key=\${SECRET_KEY}\" -var \"cluster-name=\${CLUSTER_NAME}\""
    cleanWs()
  }
}
