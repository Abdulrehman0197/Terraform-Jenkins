pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    agent any
    stages {
        stage('checkout') {
            steps {
                script {
                    dir("terraform") {
                        git branch: 'main', url: 'https://github.com/Abdulrehman0197/Terraform-Jenkins.git'
                    }
                }
            }
        }
        stage('Plan') {
            steps {
                sh 'pwd;cd terraform/ ; terraform init'
                sh "pwd;cd terraform/ ; terraform plan -out tfplan"
                sh 'pwd;cd terraform/ ; terraform show -no-color tfplan > tfplan.txt'
            }
        }
        stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }
            steps {
                script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }
        stage('Apply') {
            steps {
                sh "pwd;cd terraform/ ; terraform apply -input=false tfplan"
            }
        }
        stage('Change Permissions') {
            steps {
                script { 
                    def pemFilePath = sh(script: "cd terraform/ && terraform output -raw pem_file_path", returnStdout: true).trim()
                    // Change permissions
                    sudo chmod 400 /var/lib/jenkins/workspace/TAS-Jenkins/terraform/'${pemFilePath}' 
                }
            }
        }
        stage('Update Ansible Hosts') {
            steps {
                script {
                    // Fetch the outputs from Terraform
                    def publicIp = sh(script: "cd terraform/ && terraform output -raw aws_ec2_public_ips", returnStdout: true).trim()
                    def pemFilePath = sh(script: "cd terraform/ && terraform output -raw pem_file_path", returnStdout: true).trim()
                    def instanceName = sh(script: "cd terraform/ && terraform output -raw instance_name", returnStdout: true).trim()
                    
                    // Format and write to /etc/ansible/hosts
                    sh """
                        echo '[${instanceName}]' | sudo tee -a /etc/ansible/hosts
                        echo '${publicIp} ansible_ssh_user=ec2-user ansible_ssh_private_key_file=/var/lib/jenkins/workspace/TAS-Jenkins/terraform/${pemFilePath}' | sudo tee -a /etc/ansible/hosts
                    """
                }
            }
        }
        stage('Run Ansible Playbook') {
            steps {
                script {                   
                    
                }
            }
        }
    }
}
