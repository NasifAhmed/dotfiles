
import json
import re
from pathlib import Path

BASE_DIR = Path(__file__).parent
RAW_FILE = BASE_DIR / "raw_terms.txt"
OUTPUT_FILE = BASE_DIR / "topics.json"

# Terms to ignore completely
BLACKLIST = {
    "index", "figure", "table", "chapter", "section", "part", "volume",
    "see also", "refer to", "page", "appendix", "introduction",
    "summary", "column", "case study", "example", "solution",
    "note", "memo", "hint", "advice", "exam", "questions",
    "syllabus", "guide", "manual", "book", "textbook",
    "japanese", "english", "acronyms", "abbreviations",
    "list of", "types of", "method of", "process of",
}

# (Keyword, Domain, Subdomain, Optional: Sub-Subdomain)
# Processed in order. First match wins.
KEYWORD_RULES = [
    # --- HARDWARE & ARCHITECTURE ---
    ("cpu", "Computer Systems", "Processor", "Architecture"),
    ("processor", "Computer Systems", "Processor", "Architecture"),
    ("register", "Computer Systems", "Processor", "Architecture"),
    ("pipeline", "Computer Systems", "Processor", "Performance"),
    ("instruction", "Computer Systems", "Processor", "Instruction Set"),
    ("addressing", "Computer Systems", "Processor", "Addressing Modes"),
    ("interrupt", "Computer Systems", "Processor", "Control"),
    
    ("cache", "Computer Systems", "Memory", "Cache"),
    ("ram", "Computer Systems", "Memory", "Main Memory"),
    ("rom", "Computer Systems", "Memory", "ROM Types"),
    ("access time", "Computer Systems", "Memory", "Performance"),
    ("disk", "Computer Systems", "Storage", "Disk Drives"),
    ("raid", "Computer Systems", "Storage", "Redundancy"),
    ("storage", "Computer Systems", "Storage", "Technologies"),
    
    ("bus", "Computer Systems", "I/O Architecture", "Buses"),
    ("usb", "Computer Systems", "I/O Architecture", "Interfaces"),
    ("interface", "Computer Systems", "I/O Architecture", "Interfaces"),
    ("serial", "Computer Systems", "I/O Architecture", "Interfaces"),
    ("parallel", "Computer Systems", "I/O Architecture", "Interfaces"),
    ("device driver", "Computer Systems", "I/O Architecture", "Drivers"),

    # --- BASIC THEORY & ALGORITHMS ---
    ("radix", "Basic Theory", "Discrete Math", "Number Systems"),
    ("binary", "Basic Theory", "Discrete Math", "Number Systems"),
    ("hexadecimal", "Basic Theory", "Discrete Math", "Number Systems"),
    ("decimal", "Basic Theory", "Discrete Math", "Number Systems"),
    ("complement", "Basic Theory", "Discrete Math", "Number Systems"),
    ("logic", "Basic Theory", "Discrete Math", "Logic"),
    ("boolean", "Basic Theory", "Discrete Math", "Logic"),
    ("set", "Basic Theory", "Discrete Math", "Set Theory"),
    
    ("probability", "Basic Theory", "Applied Math", "Probability"),
    ("statistics", "Basic Theory", "Applied Math", "Statistics"),
    ("distribution", "Basic Theory", "Applied Math", "Statistics"),
    ("queueing", "Basic Theory", "Applied Math", "Queueing Theory"),
    ("markov", "Basic Theory", "Applied Math", "Stochastic Processes"),
    
    ("bit", "Basic Theory", "Information Theory", "Units"),
    ("byte", "Basic Theory", "Information Theory", "Units"),
    ("compression", "Basic Theory", "Information Theory", "Compression"),
    ("encoding", "Basic Theory", "Information Theory", "Encoding"),
    
    ("linked list", "Basic Theory", "Data Structures", "Linear"),
    ("stack", "Basic Theory", "Data Structures", "Linear"),
    ("queue", "Basic Theory", "Data Structures", "Linear"),
    ("array", "Basic Theory", "Data Structures", "Linear"),
    ("tree", "Basic Theory", "Data Structures", "Non-Linear"),
    ("graph", "Basic Theory", "Data Structures", "Non-Linear"),
    ("heap", "Basic Theory", "Data Structures", "Non-Linear"),
    ("hash", "Basic Theory", "Data Structures", "Hash Tables"),
    
    ("sort", "Basic Theory", "Algorithms", "Sorting"),
    ("search", "Basic Theory", "Algorithms", "Searching"),
    ("recursion", "Basic Theory", "Algorithms", "Techniques"),
    ("complexity", "Basic Theory", "Algorithms", "Complexity"),
    ("order", "Basic Theory", "Algorithms", "Complexity"),

    # --- OPERATING SYSTEMS ---
    ("process", "Operating Systems", "Process Management", "Basics"),
    ("thread", "Operating Systems", "Process Management", "Basics"),
    ("schedule", "Operating Systems", "Process Management", "Scheduling"),
    ("scheduling", "Operating Systems", "Process Management", "Scheduling"),
    ("deadlock", "Operating Systems", "Process Management", "Concurrency"),
    ("semaphore", "Operating Systems", "Process Management", "Synchronization"),
    ("exclusion", "Operating Systems", "Process Management", "Synchronization"),
    
    ("paging", "Operating Systems", "Memory Management", "Virtual Memory"),
    ("segmentation", "Operating Systems", "Memory Management", "Virtual Memory"),
    ("virtual memory", "Operating Systems", "Memory Management", "Virtual Memory"),
    ("allocation", "Operating Systems", "Memory Management", "Allocation"),
    ("fragmentation", "Operating Systems", "Memory Management", "Allocation"),
    
    ("file", "Operating Systems", "File System", "Basics"),
    ("directory", "Operating Systems", "File System", "Structure"),
    ("path", "Operating Systems", "File System", "Structure"),
    
    ("unix", "Operating Systems", "OS Types", "UNIX/Linux"),
    ("linux", "Operating Systems", "OS Types", "UNIX/Linux"),
    ("windows", "Operating Systems", "OS Types", "Windows"),
    ("kernel", "Operating Systems", "Architecture", "Kernel"),

    # --- NETWORKS ---
    ("osi", "Networks", "Architecture", "Models"),
    ("tcp/ip", "Networks", "Architecture", "Models"),
    ("protocol", "Networks", "Architecture", "Protocols"),
    ("lan", "Networks", "Network Types", "LAN"),
    ("wan", "Networks", "Network Types", "WAN"),
    
    ("ethernet", "Networks", "Data Link", "Standards"),
    ("mac", "Networks", "Data Link", "Direct Addressing"),
    ("switch", "Networks", "Data Link", "Devices"),
    ("vlan", "Networks", "Data Link", "Switching"),
    
    ("ip", "Networks", "Network Layer", "IP Protocol"),
    ("address", "Networks", "Network Layer", "Adressing"), # Careful with strict memory 'address'
    ("subnet", "Networks", "Network Layer", "Adressing"),
    ("route", "Networks", "Network Layer", "Routing"),
    ("routing", "Networks", "Network Layer", "Routing"),
    ("icmp", "Networks", "Network Layer", "Protocols"),
    ("arp", "Networks", "Network Layer", "Protocols"),
    
    ("tcp", "Networks", "Transport Layer", "TCP"),
    ("udp", "Networks", "Transport Layer", "UDP"),
    ("port", "Networks", "Transport Layer", "Ports"),
    
    ("http", "Networks", "Application Layer", "Web"),
    ("smtp", "Networks", "Application Layer", "Email"),
    ("pop", "Networks", "Application Layer", "Email"),
    ("imap", "Networks", "Application Layer", "Email"),
    ("dns", "Networks", "Application Layer", "Infrastructure"),
    ("dhcp", "Networks", "Application Layer", "Infrastructure"),
    ("ftp", "Networks", "Application Layer", "File Transfer"),

    # --- DATABASES ---
    ("e-r", "Databases", "Modeling", "ER Diagrams"),
    ("schema", "Databases", "Modeling", "Schema"),
    ("model", "Databases", "Modeling", "Types"),
    
    ("relational", "Databases", "RDBMS", "Concepts"),
    ("normalization", "Databases", "RDBMS", "Normalization"),
    ("join", "Databases", "RDBMS", "Operations"),
    ("index", "Databases", "RDBMS", "Optimization"), # Conflict with 'index' blacklist? 
    # Add exception logic: "index file" vs "book index"
    
    ("sql", "Databases", "SQL", "Language"),
    ("select", "Databases", "SQL", "DML"),
    ("insert", "Databases", "SQL", "DML"),
    ("update", "Databases", "SQL", "DML"),
    ("delete", "Databases", "SQL", "DML"),
    
    ("transaction", "Databases", "Transaction Processing", "Basics"),
    ("acid", "Databases", "Transaction Processing", "Properties"),
    ("lock", "Databases", "Transaction Processing", "Concurrency"),
    ("recovery", "Databases", "Transaction Processing", "Recovery"),

    # --- SECURITY ---
    ("security", "Security", "Management", "General"),
    ("confidentiality", "Security", "CIA Triad", "Concepts"),
    ("integrity", "Security", "CIA Triad", "Concepts"),
    ("availability", "Security", "CIA Triad", "Concepts"),
    ("risk", "Security", "Management", "Risk"),
    ("threat", "Security", "Management", "Risk"),
    ("vulnerability", "Security", "Management", "Risk"),
    
    ("cryptography", "Security", "Cryptography", "General"),
    ("encryption", "Security", "Cryptography", "Encryption"),
    ("key", "Security", "Cryptography", "Keys"),
    ("signature", "Security", "Cryptography", "Digital Signatures"),
    ("pki", "Security", "Cryptography", "PKI"),
    ("hash", "Security", "Cryptography", "Hash Functions"),
    
    ("authentication", "Security", "Access Control", "Authentication"),
    ("biometric", "Security", "Access Control", "Biometrics"),
    ("password", "Security", "Access Control", "Passwords"),
    
    ("virus", "Security", "Threats", "Malware"),
    ("malware", "Security", "Threats", "Malware"),
    ("worm", "Security", "Threats", "Malware"),
    ("trojan", "Security", "Threats", "Malware"),
    ("dos", "Security", "Threats", "Network Attacks"),
    ("phishing", "Security", "Threats", "Social Eng"),
    ("injection", "Security", "Threats", "App Attacks"),
    ("xss", "Security", "Threats", "App Attacks"),
    
    ("firewall", "Security", "Network Defense", "Firewalls"),
    ("vpn", "Security", "Network Defense", "VPN"),
    ("ids", "Security", "Network Defense", "IDS/IPS"),
    ("proxy", "Security", "Network Defense", "Proxy"),

    # --- DEVELOPMENT ---
    ("requirement", "Development", "System Design", "Requirements"),
    ("design", "Development", "System Design", "Design Phase"),
    ("uml", "Development", "System Design", "UML"),
    ("object", "Development", "Software Engineering", "OOP"),
    ("class", "Development", "Software Engineering", "OOP"),
    ("inheritance", "Development", "Software Engineering", "OOP"),
    ("polymorphism", "Development", "Software Engineering", "OOP"),
    ("test", "Development", "Software Engineering", "Testing"),
    ("debug", "Development", "Software Engineering", "Debugging"),
    ("maintenance", "Development", "Software Engineering", "Maintenance"),
    
    ("project", "Development", "Project Management", "General"),
    ("schedule", "Development", "Project Management", "Scheduling"),
    ("wbs", "Development", "Project Management", "Tools"),
    ("gantt", "Development", "Project Management", "Tools"),
    ("cost", "Development", "Project Management", "Cost"),
    ("quality", "Development", "Project Management", "Quality"),
    ("audit", "Development", "Management", "Audit"),

    # --- HARDWARE EXPANSION ---
    ("base-t", "Networks", "Data Link", "Ethernet Standards"),
    ("base-fx", "Networks", "Data Link", "Ethernet Standards"),
    ("bluetooth", "Networks", "Wireless", "Standards"),
    ("circuit", "Computer Systems", "Hardware", "Circuits"),
    ("converter", "Computer Systems", "Hardware", "Signal Processing"),
    ("sensor", "Computer Systems", "Hardware", "Components"),
    ("gate", "Computer Systems", "Hardware", "Logic Gates"),
    ("flip-flop", "Computer Systems", "Hardware", "Logic Circuits"),

    # --- WEB & APP DEV ---
    ("ajax", "Development", "Web Development", "Technologies"),
    ("xml", "Development", "Web Development", "Data Formats"),
    ("html", "Development", "Web Development", "Frontend"),
    ("css", "Development", "Web Development", "Frontend"),
    ("cgi", "Development", "Web Development", "Backend"),
    ("api", "Development", "Software Engineering", "Architecture"),
    
    # --- ENTERPRISE SYSTEMS ---
    ("crm", "Strategy", "Enterprise Systems", "CRM"),
    ("scm", "Strategy", "Enterprise Systems", "SCM"),
    ("erp", "Strategy", "Enterprise Systems", "ERP"),
    ("sfa", "Strategy", "Enterprise Systems", "Sales"),
    ("commerce", "Strategy", "Enterprise Systems", "E-Commerce"),
    ("b to b", "Strategy", "Enterprise Systems", "E-Commerce"),
    ("b to c", "Strategy", "Enterprise Systems", "E-Commerce"),
    
    # --- FINANCE & ACCOUNTING ---
    ("balance sheet", "Strategy", "Finance", "Accounting"),
    ("profit", "Strategy", "Finance", "Accounting"),
    ("asset", "Strategy", "Finance", "Accounting"),
    ("depreciation", "Strategy", "Finance", "Accounting"),
    ("cost", "Strategy", "Finance", "Accounting"), # Overrides Project Management cost? Order matters.
    # Let's put Finance Cost after PM Cost if we want PM focus. 
    # Actually, Cost in FE is often PM (EVM). So keep PM Cost earlier.
    
    ("financial", "Strategy", "Finance", "Analysis"),
    ("accounting", "Strategy", "Finance", "Basics"),
    
    # --- QUALITY & PROCESS ---
    ("quality", "Strategy", "Management", "Quality Control"),
    ("inspection", "Strategy", "Management", "Quality Control"),
    ("cmmi", "Development", "Process Improvement", "CMMI"),
    ("audit", "Strategy", "Management", "Audit"),
    ("iso", "Strategy", "Standards", "ISO"),

    # --- STRATEGY & MANAGEMENT ---
    ("strategy", "Strategy", "Business", "General"),
    ("analysis", "Strategy", "Business", "Analysis"),
    ("marketing", "Strategy", "Business", "Marketing"),
    ("plan", "Strategy", "Business", "Planning"),
    
    ("law", "Strategy", "Legal", "General"),
    ("act", "Strategy", "Legal", "Laws"),
    ("code", "Strategy", "Legal", "Codes"), # Civil Code etc.
    ("right", "Strategy", "Legal", "Rights"),
    ("license", "Strategy", "Legal", "Licensing"),
    ("contract", "Strategy", "Legal", "Contracts"),
    
    ("standard", "Strategy", "Standards", "General"),
    ("jis", "Strategy", "Standards", "JIS"),
    
    ("control", "Strategy", "Management", "Control"),
    ("management", "Strategy", "Management", "General"),
]

def clean_term(term):
    # Normalize
    term = term.strip()
    term = re.sub(r'[\(\uff08].*?[\)\uff09]', '', term) # Remove (...) and fullwidth parens
    term = re.sub(r' +', ' ', term)
    term = term.strip()
    return term

def build_taxonomy():
    with open(RAW_FILE) as f:
        raw_list = f.readlines()
        
    taxonomy = {}
    uncategorized = []
    
    for line in raw_list:
        original_term = line.strip()
        term_clean = clean_term(original_term)
        term_lower = term_clean.lower()
        
        # 1. Filter checks
        if not term_clean or len(term_clean) < 2: 
            continue
        if term_lower in BLACKLIST:
            continue
        if any(b in term_lower for b in BLACKLIST if len(b) > 4): # Contains blacklist word check (safeguard)
             # e.g. "figure 1"
             if "figure" in term_lower or "chapter" in term_lower:
                 continue
                 
        # 2. Map Categorization
        mapped = False
        
        # Try to find a rule match
        for keyword, domain, subdomain, subsub in KEYWORD_RULES:
            if keyword in term_lower:
                # Add to structure
                if domain not in taxonomy: taxonomy[domain] = {}
                if subdomain not in taxonomy[domain]: taxonomy[domain][subdomain] = {}
                if subsub not in taxonomy[domain][subdomain]: taxonomy[domain][subdomain][subsub] = []
                
                taxonomy[domain][subdomain][subsub].append(term_clean)
                mapped = True
                break
        
        if not mapped:
             # Try stricter match? or sub-match?
             # If no match, add to Uncategorized
             uncategorized.append(term_clean)

    # Sort
    for d in taxonomy:
        for s in taxonomy[d]:
            for ss in taxonomy[d][s]:
                taxonomy[d][s][ss] = sorted(list(set(taxonomy[d][s][ss])))

    # Save
    if uncategorized:
        if "Uncategorized" not in taxonomy: taxonomy["Uncategorized"] = {}
        taxonomy["Uncategorized"]["General"] = sorted(list(set(uncategorized)))

    with open(OUTPUT_FILE, 'w') as f:
        json.dump(taxonomy, f, indent=2)
        
    print(f"Processed {len(raw_list)} raw lines.")
    # Simple count by traversing
    count = 0
    def count_leaves(d):
        c = 0
        if isinstance(d, list): return len(d)
        for k, v in d.items():
            c += count_leaves(v)
        return c
        
    print(f"Mapped terms: {count_leaves(taxonomy)}")
    print(f"Uncategorized: {len(uncategorized)}")

if __name__ == "__main__":
    build_taxonomy()
