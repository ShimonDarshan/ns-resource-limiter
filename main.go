package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"

	v1 "k8s.io/api/admission/v1"
)

const (
	certFile string = "/tls/tls.crt"
	keyFile  string = "/tls/tls.key"
)

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)
	log.Println("Starting ns-resource-limiter server")

	http.HandleFunc("/validate", handleValidate)
	err := http.ListenAndServeTLS(":8443", certFile, keyFile, nil)
	if err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}

func handleValidate(w http.ResponseWriter, r *http.Request) {

	var admissionReviewReq v1.AdmissionReview

	reqBody, _ := io.ReadAll(r.Body)

	err := json.Unmarshal(reqBody, &admissionReviewReq)
	if err != nil {
		log.Printf("[ERROR] Failed to unmarshal admission review: %v", err)
	}

	log.Println("The all spec:")
	log.Println(string(reqBody))

	if admissionReviewReq.Request != nil {
		log.Printf("[REQUEST] Kind: %s/%s, Operation: %s, Name: %s",
			admissionReviewReq.Request.Kind.Group,
			admissionReviewReq.Request.Kind.Kind,
			admissionReviewReq.Request.Operation,
			admissionReviewReq.Request.Name)
	}

	handleIncommingRequests(admissionReviewReq)
	// response, _ := json.Marshal(reqBody)
	// response, _ := json.Marshal(admissionReviewReq)
	w.Write(reqBody)
}

func handleIncommingRequests(req v1.AdmissionReview) {

	spec := req.Request.Object.Raw
	var rawSpec map[string]interface{}
	json.Unmarshal(spec, &rawSpec)
}
