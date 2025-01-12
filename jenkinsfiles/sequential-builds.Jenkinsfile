pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  initContainers:
    - name: busybox-share-init
      image: busybox:musl
      command:
        - sh
      args:
        - -c
        - "cp -a /bin/* /busybox"
      volumeMounts:
        - name: busybox
          mountPath: /busybox
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:debug
      command:
        - /busybox/cat
      tty: true
      volumeMounts:
        - name: kaniko-secret
          mountPath: /docker
        - name: kaniko-ephemeral-storage
          mountPath: /tmp
        - name: busybox
          mountPath: /busybox
          readOnly: true
      workingDir: /home/jenkins/agent
  restartPolicy: Never
  volumes:
    - name: busybox
      emptyDir: {}
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
                    sh '/kaniko/executor --context . --dockerfile ./heavy-node-project/optimized.Dockerfile --destination ttl.sh/heavy-next-js-project:1h'
                    sh '/kaniko/executor --context . --dockerfile ./echo-server/optimized.Dockerfile --destination ttl.sh/echo-server:1h'
                }
            }
        }
    }
}
