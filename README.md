# 🚗 Electra Cars Intelligent Warranty Automation Agent

## 📌 Overview

This project is a multi-channel warranty automation system built using Salesforce, Slack, and WhatsApp.

It enables dealers to submit claims via WhatsApp, automates warranty validation using Salesforce Flow, and allows OEMs to approve or reject claims directly from Slack.

---

## 🚀 Features

### 📱 WhatsApp Claim Submission

* Conversational agent collects:

  * VIN
  * Part Name
  * Issue Description
  * Invoice Date
  * Vehicle Type
  * Dealer Name

### 📄 Invoice Validation

* Upload PDF invoice
* System validates dealer input

### 🔔 Slack Notifications

* New claim alerts sent to OEM Slack channel

### ⚙️ Automated Decision Logic

* < 1 year → Auto Approved
* 1–2 years → Under Review (Slack approval)
* > 2 years → Auto Rejected

### 🔘 Slack Approval Buttons

* Approve/Reject directly from Slack
* Duplicate action prevention

### 🔄 Real-time Notifications

* Dealers receive updates via WhatsApp

---

## 🛠️ Tech Stack

* Salesforce Apex (REST APIs, Queueable)
* Salesforce Flow
* Agentforce (AI agent)
* Slack API
* WhatsApp Business API
* SOQL
* Experience Cloud

---

## 🎥 Demo Video

[https://drive.google.com/file/d/1TPCTofZy4410xnAN1Jrx5RBTde8unn4w/view?usp=drivesdk]

---

## 💻 Setup Instructions

1. Deploy Apex classes in Salesforce
2. Activate Flows
3. Configure Slack:

   * Slash Command
   * Interactivity
4. Configure WhatsApp API
5. Ensure public endpoint via Experience Cloud

---

## 🔮 Future Improvements

* AI-based fraud detection
* Analytics dashboard
* Multi-language support
* Role-based approvals

---

## 📜 License

This project is part of a hackathon submission and is for demonstration purposes.
