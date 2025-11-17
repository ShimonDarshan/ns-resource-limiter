package main

import (
	"encoding/json"
	"fmt"
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
	fmt.Println("Starting ns-resource-limiter server")
	http.HandleFunc("/validate", handleValidate)
	http.ListenAndServeTLS(":8443", certFile, keyFile, nil)
}

func handleValidate(w http.ResponseWriter, r *http.Request) {

	var admissionReviewReq v1.AdmissionReview

	reqBody, _ := io.ReadAll(r.Body)
	json.Unmarshal(reqBody, &admissionReviewReq)

	handleIncommingRequests(admissionReviewReq)

	myStr := string(reqBody)
	log.Println(myStr)
	// response, _ := json.Marshal(reqBody)
	// response, _ := json.Marshal(admissionReviewReq)
	w.Write(reqBody)
}

func handleIncommingRequests(req v1.AdmissionReview) {

	spec := req.Request.Object.Raw
	var rawSpec map[string]interface{}
	json.Unmarshal(spec, &rawSpec)
}
