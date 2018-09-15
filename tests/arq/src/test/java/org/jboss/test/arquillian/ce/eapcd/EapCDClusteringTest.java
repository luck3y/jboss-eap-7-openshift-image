package org.jboss.test.arquillian.ce.eapcd;

import org.arquillian.cube.openshift.api.OpenShiftResource;
import org.arquillian.cube.openshift.api.Template;
import org.arquillian.cube.openshift.api.TemplateParameter;
import org.jboss.arquillian.junit.Arquillian;
import org.jboss.test.arquillian.ce.common.EapClusteringTestBase;
import org.junit.Ignore;
import org.junit.runner.RunWith;
import org.arquillian.cube.openshift.api.AddRoleToServiceAccount;
/**
 * @author Jonh Wendell
 * org.jboss.test.arquillian.ce.eapcd.EapCDClusteringTest
 */
@RunWith(Arquillian.class)
@Template(url = "${template.uri}/eap-cd-basic-s2i.json", parameters = {
        @TemplateParameter(name = "SOURCE_REPOSITORY_URL", value = "https://github.com/jboss-openshift/openshift-examples"),
        @TemplateParameter(name = "SOURCE_REPOSITORY_REF", value = "master"),
        @TemplateParameter(name = "CONTEXT_DIR", value = "eap-tests/cluster1") })
@OpenShiftResource("https://raw.githubusercontent.com/${secrets.repository:jboss-openshift}/application-templates/${secrets.branch:master}/secrets/eap7-app-secret.json")
// these roles are required for KUBE_PING, the template default is DNS_PING.
@AddRoleToServiceAccount(role = "view", serviceAccount = "system:serviceaccount:${kubernetes.namespace}:default" )
@AddRoleToServiceAccount(role = "view", serviceAccount = "system:serviceaccount:${kubernetes.namespace}:eap7-service-account")
public class EapCDClusteringTest extends EapClusteringTestBase {
}
