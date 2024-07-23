pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        SUDO_PASSWORD         = credentials('SUDO_PASSWORD_ID') // Add this line
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
        stage('Update Ansible Hosts') {
            steps {
                script {
                    // Fetch the outputs from Terraform
                    def publicIp = sh(script: "cd terraform/ && terraform output -raw aws_ec2_public_ips", returnStdout: true).trim()
                    def pemFilePath = sh(script: "cd terraform/ && terraform output -raw pem_file_path", returnStdout: true).trim()
                    def instanceName = sh(script: "cd terraform/ && terraform output -raw instance_name", returnStdout: true).trim()
                    
                    // Format and write to /etc/ansible/hosts
                    sh """
                        echo '${SUDO_PASSWORD}' | sudo -S sh -c "echo '[${instanceName}]' >> /etc/ansible/hosts"
                        echo '${SUDO_PASSWORD}' | sudo -S sh -c "echo '${publicIp} ansible_ssh_user=ec2-user ansible_ssh_private_key_file=/var/lib/jenkins/workspace/IAC-Script/terraform/DEMO_KP' >> /etc/ansible/hosts"
                    """
                }
            }
        }
        stage('Format Disk and Execute Ansible Playbook') {
            steps {
                script {
                    def startAtTask = "Run Solr installation script"
                    
                    // Change permissions
                    sh """
                        echo '${SUDO_PASSWORD}' | sudo -S chmod 400 /var/lib/jenkins/workspace/IAC-Script/terraform/DEMO_KP
                    """
                    
                    // Format the disk
                    sh """
                        ansible IAC-DEMO -i /etc/ansible/hosts -m shell -a "sudo mkfs -t ext4 /dev/nvme1n1" -b
                    """

                    

                    // Run ansible-playbook
                    sh """
                        echo '${SUDO_PASSWORD}' | sudo -S ansible-playbook -i /etc/ansible/hosts /var/lib/jenkins/workspace/IAC-Script/terraform/play.yml
                    """
                }
            }
        }
    }
}
