# Hints for s17

Create a CustomResourceDefinition:
\`\`\`bash
kubectl apply -f - << 'CRD'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: bookings.example.com
spec:
  group: example.com
  names:
    kind: Booking
    plural: bookings
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
CRD
\`\`\`

Key: Understand CRD structure and API groups.
