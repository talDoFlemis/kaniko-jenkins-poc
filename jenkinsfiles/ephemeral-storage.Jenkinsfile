pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:debug
      command:
        - sleep
      args:
        - 3600
      volumeMounts:
        - name: kaniko-secret
          mountPath: /docker
        - name: kaniko-ephemeral-storage
          mountPath: /tmp
  restartPolicy: Never
  volumes:
    - name: kaniko-secret
      secret:
        secretName: jenkins-harbor-service-account
        items:
          - key: .dockerconfigjson
            path: config.json
    - name: kaniko-ephemeral-storage
      ephemeral:
        volumeClaimTemplate:
          spec:
            accessModes: ["ReadWriteOnce"]
            storageClassName: "default-storage-class-1"
            resources:
              requests:
                storage: 10Gi
        '''
        }
    }
    stages {
        stage('Release') {
            steps {
                container('kaniko') {
                    sh 'cp /docker/config.json /kaniko/.docker/'
                    sh 'KANIKO_DIR=/tmp/kaniko /kaniko/executor --context . --dockerfile ./heavy-node-project/optimized.Dockerfile --destination ttl.sh/heavy-next-js-project:1h'
                }
            }
        }
    }
}
