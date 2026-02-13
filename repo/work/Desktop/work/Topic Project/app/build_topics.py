#!/usr/bin/env python3
"""
Build Topics Taxonomy for FE Question Bank
Aligned with New FE Textbook Vol 1 & 2
Structure: Chapter (Category) > Section (Subcategory) > Topic (Specific)
"""

import json
import re
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent
RAW_FILE = BASE_DIR / "data" / "output" / "raw_terms.txt"
OUTPUT_FILE = BASE_DIR / "data" / "output" / "topics.json"

BLACKLIST = {
    "index", "figure", "table", "chapter", "section", "part", "volume",
    "see also", "refer to", "page", "appendix", "introduction", "general",
    "various", "other", "etc", "using", "used", "made", "given", "following",
    "exercises", "column", "summary", "memo"
}

# (Keyword/Regex, Category (Chapter), Subcategory (Section), Optional: Specific Topic)
# Priority: Top to Bottom
KEYWORD_RULES = [
    # --- Vol 1. Chapter 1: Hardware ---
    (r"\b(cpu|processor|alu|register|clock|instruction set|addressing mode)\b", "Hardware", "Central Processing Unit and Main Memory Unit", "CPU Architecture"),
    (r"\b(main memory|ram|rom|cache|memory hierarchy|access time)\b", "Hardware", "Central Processing Unit and Main Memory Unit", "Memory"),
    (r"\b(auxiliary storage|hard disk|hdd|ssd|flash memory|optical disc|raid|magnetic tape)\b", "Hardware", "Auxiliary Storage", "Storage Devices"),
    (r"\b(input unit|output unit|display|printer|scanner|keyboard|mouse|ocr|omr)\b", "Hardware", "Input/Output Unit", "I/O Devices"),
    (r"\b(interface|usb|serial|parallel|bluetooth|hdmi|irda|rfid|nfc)\b", "Hardware", "Input/Output Unit", "Interfaces"),
    (r"\b(binary|decimal|hexadecimal|radix|complement|floating point|fixed point|error)\b", "Hardware", "Data Representation in Computers", "Number Representation"),
    (r"\b(logic circuit|logic gate|boolean|truth table|combinational circuit|sequential circuit|flip-flop)\b", "Hardware", "Basic Configuration of Computers", "Logic Circuits"),

    # --- Vol 1. Chapter 2: Information Processing System ---
    (r"\b(client/server|client-server|thin client|rich client|3-tier|web system)\b", "Information Processing System", "Processing Type of Information Processing System", "System Architecture"),
    (r"\b(cloud computing|saas|paas|iaas|daas|virtualization)\b", "Information Processing System", "Processing Type of Information Processing System", "Cloud & Virtualization"),
    (r"\b(raid|reliability|availability|mtbf|mttr|fault tolerant|redundancy|backup)\b", "Information Processing System", "Configuration of High-reliability System", "Reliability"),
    (r"\b(performance|throughput|response time|turnaround time|benchmark)\b", "Information Processing System", "Evaluation of Information Processing System", "Performance Evaluation"),
    (r"\b(multimedia|mp3|jpeg|mpeg|gif|compression|encoding)\b", "Information Processing System", "Multimedia", "Multimedia Tech"),
    (r"\b(gui|user interface|usability|accessibility|universal design)\b", "Information Processing System", "Human Interface", "UI/UX"),

    # --- Vol 1. Chapter 3: Software ---
    (r"\b(os|operating system|kernel|process management|job management|memory management|virtual memory)\b", "Software", "OS (Operating System)", "OS Functions"),
    (r"\b(file system|directory|file allocation|access method|backup)\b", "Software", "Files", "File Management"),
    (r"\b(programming language|compiler|interpreter|linker|loader|java|c\+\+|script)\b", "Software", "Programming Languages and Language Processors", "Languages & Tools"),
    (r"\b(oss|open source|license|copyright|freeware|shareware)\b", "Software", "Classification of Software", "Software Licenses"),

    # --- Vol 1. Chapter 4: Database ---
    (r"\b(sql|select|insert|update|delete|create table|view|grant)\b", "Database", "SQL", "SQL Commands"),
    (r"\b(dbms|transaction|acid|lock|concurrency|deadlock|commit|rollback)\b", "Database", "Outline of Database", "DBMS Functions"),
    (r"\b(normalization|e-r|entity relationship|data model|schema)\b", "Database", "Outline of Database", "Database Design"),
    (r"\b(data warehouse|data mining|big data|distributed database|nosql)\b", "Database", "Various Databases", "Advanced DB"),

    # --- Vol 1. Chapter 5: Network ---
    (r"\b(osi|tcp/ip|network layer|transport layer|ip address|subnet|ipv4|ipv6)\b", "Network", "Network Architecture", "Protocols & Models"),
    (r"\b(lan|ethernet|switching hub|router|vlan|arp|mac address)\b", "Network", "LAN", "Local Area Network"),
    (r"\b(internet|http|dns|email|smtp|pop|imap|ftp|www)\b", "Network", "The Internet", "Internet Services"),
    (r"\b(network management|snmp|traffic|packet|routing)\b", "Network", "Network Management", "Management"),
    (r"\b(transmission|modulation|multiplexing|error control|synchronization)\b", "Network", "Network Mechanism", "Transmission Tech"),

    # --- Vol 1. Chapter 6: Security ---
    (r"\b(encryption|cryptography|public key|private key|digital signature|pki|certificate)\b", "Security", "Information Security Measures", "Cryptography"),
    (r"\b(authentication|password|biometric|access control|firewall|ids|ips|vpn)\b", "Security", "Information Security Measures", "Network Security"),
    (r"\b(malware|virus|worm|trojan|ransomware|phishing|dos|ddos|sql injection|xss)\b", "Security", "Information Security Measures", "Threats"),
    (r"\b(risk management|isms|security policy|information assets|confidentiality|integrity|availability)\b", "Security", "Overview of Information Security", "Security Management"),

    # --- Vol 1. Chapter 7: Data Structure and Algorithm ---
    (r"\b(array|list|stack|queue|tree|graph|heap|hash)\b", "Data Structure and Algorithm", "Data Structure", "Structures"),
    (r"\b(algorithm|flowchart|pseudo-code|recursion)\b", "Data Structure and Algorithm", "Basic Algorithm", "Basics"),
    (r"\b(sort|search|bubble|selection|insertion|merge|quick|heap|binary search|linear search)\b", "Data Structure and Algorithm", "Basic Algorithm", "Sort & Search"),

    # --- Vol 2. Chapter 1: Corporate and Legal Affairs ---
    (r"\b(corporate strategy|business plan|swot|ppm|marketing|4p|3c)\b", "Corporate and Legal Affairs", "Corporate Activities", "Strategy"),
    (r"\b(financial|accounting|balance sheet|profit and loss|cash flow|roi|break-even)\b", "Corporate and Legal Affairs", "Corporate Accounting", "Finance"),
    (r"\b(intellectual property|copyright|patent|trademark|trade secret)\b", "Corporate and Legal Affairs", "Legal Affairs and Standardization", "IP Rights"),
    (r"\b(labor|employment|contract|dispatch|outsourcing|compliance|governance)\b", "Corporate and Legal Affairs", "Legal Affairs and Standardization", "Legal & Compliance"),
    (r"\b(or|operations research|linear programming|game theory|queueing theory|statistics|probability)\b", "Corporate and Legal Affairs", "Management Science", "OR & Math"),

    # --- Vol 2. Chapter 2: Business Strategy ---
    (r"\b(business strategy|value chain|core competence|m&a|alliance)\b", "Business Strategy", "Business Strategy Management", "Strategic Mgmt"),
    (r"\b(technological strategy|mot|innovation|roadmap)\b", "Business Strategy", "Technological Strategy Management", "Tech Strategy"),
    (r"\b(business industry|e-business|erp|scm|crm|sfa|pos|ic card|rfid)\b", "Business Strategy", "Business Industry", "Business Systems"),

    # --- Vol 2. Chapter 3: Information Systems Strategy ---
    (r"\b(system planning|requirements definition|procurement|rfp|proposal|sourcing)\b", "Information Systems Strategy", "Information System Planning", "Planning"),
    (r"\b(information systems strategy|ea|enterprise architecture|business process|bpr|bpm)\b", "Information Systems Strategy", "Overview of Information Systems Strategy", "Strategy Overview"),

    # --- Vol 2. Chapter 4: Development Technology ---
    (r"\b(slcp|software life cycle|waterfall|agile|prototyping|spiral|devops)\b", "Development Technology", "System Development Technology (SLCP)", "Process Models"),
    (r"\b(requirements analysis|external design|internal design|coding|testing|maintenance)\b", "Development Technology", "System Development Technology (SLCP)", "Development Phases"),
    (r"\b(object-oriented|uml|class diagram|use case|sequence diagram)\b", "Development Technology", "Software Development Technology", "Object-Oriented Dev"),
    (r"\b(testing|unit test|integration test|system test|white box|black box)\b", "Development Technology", "Software Development Technology", "Testing"),

    # --- Vol 2. Chapter 5: Project Management ---
    (r"\b(project management|pmbok|wbs|schedule|gantt|pert|critical path)\b", "Project Management", "Project Management Overview", "Time Mgmt"),
    (r"\b(cost|budget|quality|risk|stakeholder|scope)\b", "Project Management", "Subject Group Management", "Project Areas"),

    # --- Vol 2. Chapter 6: Service Management ---
    (r"\b(service management|itil|sla|slm|service desk|incident|problem|change)\b", "Service Management", "Method of Service Management", "Service Operations"),
    (r"\b(service design|service transition|service operation|continual service improvement)\b", "Service Management", "Overview of Service Management", "ITIL Lifecycle"),

    # --- Vol 2. Chapter 7: System Audit and Internal Control ---
    (r"\b(system audit|auditor|audit report|audit evidence|audit plan)\b", "System Audit and Internal Control", "System Audit", "Audit Process"),
    (r"\b(internal control|it governance|compliance|risk management)\b", "System Audit and Internal Control", "Internal Control", "Governance"),
]

def clean_term(term):
    term = re.sub(r'\(.*?\)', '', term)
    term = re.sub(r'[\(\)\[\]]', '', term)
    term = term.strip()
    return term

def build_taxonomy():
    if not RAW_FILE.exists():
        print("Error: raw_terms.txt not found.")
        return
    
    with open(RAW_FILE) as f:
        raw_list = f.readlines()
        
    taxonomy = {}
    
    # Pre-compile regex
    compiled_rules = []
    for pattern, cat, sub, *top in KEYWORD_RULES:
        compiled_rules.append((re.compile(pattern, re.IGNORECASE), cat, sub, top[0] if top else "General"))

    for line in raw_list:
        original_term = line.strip()
        if not original_term: continue
        
        term_clean = clean_term(original_term)
        if not term_clean or term_clean.lower() in BLACKLIST or len(term_clean) < 2:
            continue
            
        for regex, cat, sub, top in compiled_rules:
            if regex.search(original_term):
                if cat not in taxonomy: taxonomy[cat] = {}
                if sub not in taxonomy[cat]: taxonomy[cat][sub] = {}
                if top not in taxonomy[cat][sub]: taxonomy[cat][sub][top] = []
                
                taxonomy[cat][sub][top].append(original_term)
                break # Stop at first match (priority)

    # Sort and clean
    sorted_taxonomy = {}
    for cat in sorted(taxonomy.keys()):
        sorted_taxonomy[cat] = {}
        for sub in sorted(taxonomy[cat].keys()):
            sorted_taxonomy[cat][sub] = {}
            for top in sorted(taxonomy[cat][sub].keys()):
                terms = sorted(list(set(taxonomy[cat][sub][top])))
                if terms:
                    sorted_taxonomy[cat][sub][top] = terms

    with open(OUTPUT_FILE, 'w') as f:
        json.dump(sorted_taxonomy, f, indent=2)
    print(f"✓ FE Textbook-Aligned Taxonomy Rebuilt! Saved to {OUTPUT_FILE}")

if __name__ == "__main__":
    build_taxonomy()
