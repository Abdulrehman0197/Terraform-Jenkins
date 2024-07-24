pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        // SUDO_PASSWORD         = credentials('SUDO_PASSWORD_ID') // Add this line
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
                        echo '[${instanceName}]' | sudo tee -a /etc/ansible/hosts
                        echo '${publicIp} ansible_ssh_user=ec2-user ansible_ssh_private_key_file=/var/lib/jenkins/workspace/TAS-Jenkins/terraform/DEMO_KP' | sudo tee -a /etc/ansible/hosts
                        // echo '${SUDO_PASSWORD}' | sudo -S sh -c "echo '[${instanceName}]' >> /etc/ansible/hosts"
                        // echo '${SUDO_PASSWORD}' | sudo -S sh -c "echo '${publicIp} ansible_ssh_user=ec2-user ansible_ssh_private_key_file=/var/lib/jenkins/workspace/TAS-Jenkins/terraform/DEMO_KP' >> /etc/ansible/hosts"
                    """
                }
            }
        }
        stage('Change Permissions') {
            steps {
                script {
                    def startAtTask = "Run Solr installation script"
                    def instanceName = sh(script: "cd terraform/ && terraform output -raw instance_name", returnStdout: true).trim()
                    
                    // Change permissions
                
                    // sudo chmod 400 /var/lib/jenkins/workspace/TAS-Jenkins/terraform/DEMO_KP
                    
                    // Define the Redis keys and the commands
                    REDIS_KEY_CHMOD_RUN="chmod_run"
                    INSTANCE_NAME="\${instanceName}"  
                    CHMOD_COMMAND="sudo chmod 400 /var/lib/jenkins/workspace/TAS-Jenkins/terraform/\${INSTANCE_NAME}"
                    
                    // Check if the chmod command has already run
                    CHMOD_RUN=$(redis-cli GET $REDIS_KEY_CHMOD_RUN)
                    
                    if [ "$CHMOD_RUN" != "true" ]; then
                        # Run the chmod command
                        echo "Running chmod command..."
                        eval $CHMOD_COMMAND
                    
                        # Set the Redis key to indicate the chmod command has run
                        redis-cli SET $REDIS_KEY_CHMOD_RUN true
                    else
                        echo "Chmod command already run. Skipping..."
                    fi

                    
                    // echo '${SUDO_PASSWORD}' | sudo -S chmod 400 /var/lib/jenkins/workspace/TAS-Jenkins/terraform/DEMO_KP
                   
                    
                    // Format the disk
                    // sh """
                    //     ansible '${instanceName}' -i /etc/ansible/hosts -m shell -a "sudo mkfs -t ext4 /dev/xvdb" -b

                    //     #!/bin/bash
                    //     # Define the Redis key and the Ansible command
                    //     REDIS_KEY="command_run"
                    //     INSTANCE_NAME="${instanceName}"  # Ensure instanceName is set appropriately
                    //     ANSIBLE_COMMAND="ansible '${INSTANCE_NAME}' -i /etc/ansible/hosts -m shell -a 'sudo mkfs -t ext4 /dev/xvdb' -b"
                        
                    //     # Check if the command has already run
                    //     COMMAND_RUN=$(redis-cli GET $REDIS_KEY)
                        
                    //     if [ "$COMMAND_RUN" != "true" ]; then
                    //         # Run the Ansible command
                    //         echo "Running Ansible command..."
                    //         eval $ANSIBLE_COMMAND
                        
                    //         # Set the Redis key to indicate the command has run
                    //         redis-cli SET $REDIS_KEY true
                    //     else
                    //         echo "Command already run. Skipping..."
                    //     fi
                    // """

                    

                    // Run ansible-playbook
                    // sh """
                    //     sudo ansible-playbook -i /etc/ansible/hosts /var/lib/jenkins/workspace/TAS-Jenkins/terraform/play.yml
                    //     // echo '${SUDO_PASSWORD}' | sudo -S ansible-playbook -i /etc/ansible/hosts /var/lib/jenkins/workspace/TAS-Jenkins/terraform/play.yml
                    // """
                }
            }
        }
    }
}
