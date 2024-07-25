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
        stage('Run Ansible Playbook') {
            steps {
                script {
                    def instanceName = sh(script: "cd terraform/ && terraform output -raw instance_name", returnStdout: true).trim()
                    def diskName = sh(script: "lsblk -o NAME,SIZE -b | awk '$2 == 125000000000 {print $1}'", returnStdout: true).trim()
                    
                    if (diskName) {
                        echo "Disk with 125GB size: ${diskName}"
                        // Proceed with formatting the disk
                        sh "ansible ${instanceName} -i /etc/ansible/hosts -m shell -a 'sudo mkfs -t ext4 /dev/${diskName}' -b"
                    } else {
                        error "No disk found with 125GB size"
                    }
                }
            }
        }
        stage('Change Permissions') {
            steps {
                script { 
                    def pemFilePath = sh(script: "cd terraform/ && terraform output -raw pem_file_path", returnStdout: true).trim()
                    // Change permissions
                    sh "sudo chmod 400 /var/lib/jenkins/workspace/TAS-Jenkins/terraform/${pemFilePath}"
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
        
                    // Check if the group exists and the specific line exists
                    def groupExists = sh(script: "grep -q '^\\[${instanceName}\\]' /etc/ansible/hosts && echo 'found' || echo 'not found'", returnStdout: true).trim()
                    def lineExists = sh(script: "grep -q '${publicIp} ansible_ssh_user=ec2-user ansible_ssh_private_key_file=/var/lib/jenkins/workspace/TAS-Jenkins/terraform/${pemFilePath}' /etc/ansible/hosts && echo 'found' || echo 'not found'", returnStdout: true).trim()
        
                    if (groupExists == 'not found' || lineExists == 'not found') {
                        // If group not found or the specific line not found, append to /etc/ansible/hosts
                        sh """
                            if [ "${groupExists}" == "not found" ]; then
                                echo '[${instanceName}]' | sudo tee -a /etc/ansible/hosts
                            fi
                            if [ "${lineExists}" == "not found" ]; then
                                echo '${publicIp} ansible_ssh_user=ec2-user ansible_ssh_private_key_file=/var/lib/jenkins/workspace/TAS-Jenkins/terraform/${pemFilePath}' | sudo tee -a /etc/ansible/hosts
                            fi
                        """
                    }
                }
            }
        }
        stage('Run Ansible Playbook') {
            steps {
                script {                   
                    sh """
                        sudo  
                    """
                }
            }
        }
    }
}
