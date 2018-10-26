@jboss-eap-7 @jboss-eap-7-tech-preview
Feature: Openshift EAP jgroups secure
  Scenario: jgroups-encrypt
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_SECRET                       | eap_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then container log should contain WFLYSRV0039:
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='encrypt-protocol'][@type='SYM_ENCRYPT']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value keystore.jks on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/@key-store
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jboss on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/@key-alias
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeystorepass on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/*[local-name()="key-credential-reference"]/@clear-text
     # https://issues.jboss.org/browse/CLOUD-1192
     # https://issues.jboss.org/browse/CLOUD-1196
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for udp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK2 on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/following-sibling::*[1]/@type
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for tcp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK2 on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/following-sibling::*[1]/@type

  # CLOUD-336
  Scenario: Check if jgroups is secure
    When container is started with env
       | variable                 | value    |
       | JGROUPS_CLUSTER_PASSWORD | asdfasdf |
       | OPENSHIFT_KUBE_PING_NAMESPACE                | openshift.DNS_PING                      |

    Then container log should contain WFLYSRV0025:
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='auth-protocol'][@type='AUTH']

  Scenario: Check jgroups encryption does not create invalid configuration with missing name
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
       | OPENSHIFT_KUBE_PING_NAMESPACE                | openshift.DNS_PING                      |
    Then container log should contain WFLYSRV0025:
     And available container log should contain WARN Detected partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.

  Scenario: Check jgroups encryption does not create invalid configuration with missing password
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | OPENSHIFT_KUBE_PING_NAMESPACE                | openshift.DNS_PING                      |
    Then container log should contain WFLYSRV0025:
     And available container log should contain WARN Detected partial JGroups encryption configuration, the communication within the cluster WILL NOT be encrypted.
