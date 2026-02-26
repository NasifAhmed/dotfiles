import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Network, 
  Database, 
  ShieldCheck, 
  ArrowRightLeft, 
  Send, 
  HelpCircle,
  Activity,
  Cpu,
  Wifi,
  ChevronRight,
  ChevronLeft,
  RotateCcw,
  Globe,
  Lock,
  MessageSquare,
  Truck,
  Map,
  Link,
  Zap
} from 'lucide-react';
import './App.css';

interface Layer {
  id: number;
  name: string;
  fullName: string;
  description: string;
  data: string;
  icon: React.ReactNode;
  color: string;
}

const OSI_LAYERS: Layer[] = [
  { id: 7, name: 'L7', fullName: 'Application', icon: <Globe size={20} />, color: '#ef4444', description: 'User interfaces & network processes (HTTP, DNS, DHCP)', data: 'User Input / URL' },
  { id: 6, name: 'L6', fullName: 'Presentation', icon: <Lock size={20} />, color: '#f97316', description: 'Data representation & encryption (SSL, SSH, JPEG)', data: 'Encrypted / Formatted Data' },
  { id: 5, name: 'L5', fullName: 'Session', icon: <MessageSquare size={20} />, color: '#eab308', description: 'Interhost communication, session tracking (RPC, SQL)', data: 'Session ID / Context' },
  { id: 4, name: 'L4', fullName: 'Transport', icon: <Truck size={20} />, color: '#22c55e', description: 'End-to-end connections & reliability (TCP, UDP)', data: 'Segments / Port Numbers' },
  { id: 3, name: 'L3', fullName: 'Network', icon: <Map size={20} />, color: '#06b6d4', description: 'Path determination & logical addressing (IP, ICMP)', data: 'Packets / IP Addresses' },
  { id: 2, name: 'L2', fullName: 'Data Link', icon: <Link size={20} />, color: '#3b82f6', description: 'Physical addressing (MAC, ARP, Ethernet)', data: 'Frames / MAC Addresses' },
  { id: 1, name: 'L1', fullName: 'Physical', icon: <Zap size={20} />, color: '#8b5cf6', description: 'Binary transmission, cables, connectors', data: 'Bits / Volts / Light' },
];

const App: React.FC = () => {
  const [currentStep, setCurrentStep] = useState(0);
  const [activeProtocol, setActiveProtocol] = useState<'none' | 'DNS' | 'DHCP' | 'ARP'>('none');
  const [isDescending, setIsDescending] = useState(true);
  const [packetData, setPacketData] = useState<string>('');

  useEffect(() => {
    updatePacketData();
  }, [currentStep, activeProtocol, isDescending]);

  const updatePacketData = () => {
    if (activeProtocol === 'none') {
      setPacketData(OSI_LAYERS[currentStep].data);
      return;
    }

    const layer = OSI_LAYERS[currentStep];
    let data = '';

    if (activeProtocol === 'DNS') {
      switch(layer.id) {
        case 7: data = "Query: 'google.com' type: A"; break;
        case 4: data = "UDP Source: 54321, Dest: 53"; break;
        case 3: data = "IP Src: 192.168.1.5, Dest: 8.8.8.8"; break;
        case 2: data = "Ethernet II, Src: AA:BB:CC, Dest: DD:EE:FF"; break;
        default: data = layer.data;
      }
    } else if (activeProtocol === 'DHCP') {
      switch(layer.id) {
        case 7: data = "DHCP DISCOVER (Broadcast)"; break;
        case 4: data = "UDP Source: 68, Dest: 67"; break;
        case 3: data = "IP Src: 0.0.0.0, Dest: 255.255.255.255"; break;
        case 2: data = "MAC Src: Client_MAC, Dest: FF:FF:FF:FF:FF:FF"; break;
        default: data = layer.data;
      }
    } else if (activeProtocol === 'ARP') {
      switch(layer.id) {
        case 3: data = "Who has 192.168.1.1? Tell 192.168.1.5"; break;
        case 2: data = "ARP Request, Dest: Broadcast (FF:FF:FF:FF:FF:FF)"; break;
        default: data = layer.data;
      }
    }
    setPacketData(data);
  };

  const nextStep = () => {
    if (isDescending) {
      if (currentStep < 6) setCurrentStep(currentStep + 1);
      else setIsDescending(false);
    } else {
      if (currentStep > 0) setCurrentStep(currentStep - 1);
      else setIsDescending(true);
    }
  };

  const prevStep = () => {
    if (isDescending) {
      if (currentStep > 0) setCurrentStep(currentStep - 1);
    } else {
      if (currentStep < 6) setCurrentStep(currentStep + 1);
    }
  };

  const reset = () => {
    setCurrentStep(0);
    setIsDescending(true);
    setActiveProtocol('none');
  };

  const getStepDescription = () => {
    const layer = OSI_LAYERS[currentStep];
    const direction = isDescending ? 'down' : 'up';
    
    if (activeProtocol === 'DNS') {
      if (isDescending) {
        switch(layer.id) {
          case 7: return "DNS Client generates a query for 'google.com'.";
          case 6: return "System handles any required character encoding/formatting.";
          case 5: return "Session established for the DNS transaction.";
          case 4: return "Encapsulated into a UDP segment targeting port 53.";
          case 3: return "Encapsulated into an IP packet with public DNS server address.";
          case 2: return "Framed for Ethernet; uses ARP if Gateway MAC is unknown.";
          case 1: return "Bits are pulsed over the physical medium (Copper/Fiber/WiFi).";
        }
      } else {
        return `Decapsulating: Moving ${direction} the stack with DNS Response.`;
      }
    }

    if (activeProtocol === 'DHCP') {
      if (layer.id > 3) return "DHCP starts at the Application layer and prepares a request.";
      if (layer.id === 3) return "DHCP uses broadcast (255.255.255.255) to find a server.";
      if (layer.id === 2) return "Layer 2 frames the broadcast with FF:FF:FF:FF:FF:FF.";
    }

    if (activeProtocol === 'ARP') {
      if (layer.id > 3) return "ARP is a Layer 2 protocol but triggered by Layer 3 IP needs.";
      if (layer.id === 3) return "Network layer needs the MAC for IP 192.168.1.1.";
      if (layer.id === 2) return "ARP builds a 'Who has...?' request packet.";
    }

    return layer.description;
  };

  return (
    <div className="app-container">
      <header className="app-header">
        <h1>Networking Interactive Demo</h1>
        <p>A step-by-step visualizer for OSI layers and protocols</p>
      </header>

      <main className="demo-content">
        <section className="controls-panel">
          <div className="protocol-selector">
            <h3>Select Scenario</h3>
            <div className="protocol-buttons">
              <button 
                className={activeProtocol === 'none' ? 'active' : ''} 
                onClick={() => { setActiveProtocol('none'); setCurrentStep(0); }}
              >
                Generic Flow
              </button>
              <button 
                className={activeProtocol === 'DNS' ? 'active' : ''} 
                onClick={() => { setActiveProtocol('DNS'); setCurrentStep(0); }}
              >
                DNS Resolution
              </button>
              <button 
                className={activeProtocol === 'DHCP' ? 'active' : ''}
                onClick={() => { setActiveProtocol('DHCP'); setCurrentStep(0); setIsDescending(true); }}
              >
                DHCP Discovery
              </button>
              <button 
                className={activeProtocol === 'ARP' ? 'active' : ''}
                onClick={() => { setActiveProtocol('ARP'); setCurrentStep(4); setIsDescending(true); }}
              >
                ARP Request
              </button>
            </div>
          </div>

          <div className="navigation-controls">
            <button onClick={prevStep} disabled={currentStep === (isDescending ? 0 : 6)}>
              <ChevronLeft size={20} /> Back
            </button>
            <button onClick={reset}>
              <RotateCcw size={16} /> Reset
            </button>
            <button onClick={nextStep} disabled={!isDescending && currentStep === 0}>
              {currentStep === 6 && isDescending ? 'Simulate Send' : 'Next Step'} <ChevronRight size={20} />
            </button>
          </div>

          <div className="step-info">
            <h3>{isDescending ? 'Encapsulation' : 'Decapsulation'}: {OSI_LAYERS[currentStep].fullName}</h3>
            <p className="description">{getStepDescription()}</p>
            <div className="data-inspector">
              <strong>Header / Data Payload:</strong>
              <code>{packetData}</code>
            </div>
          </div>
        </section>

        <section className="osi-stack-visual">
          <div className="stack-container">
            <AnimatePresence mode='wait'>
            {OSI_LAYERS.map((layer, index) => (
              <motion.div 
                key={layer.id}
                className={`layer-box ${currentStep === index ? 'active' : ''}`}
                initial={{ x: -20, opacity: 0 }}
                animate={{ 
                  x: 0, 
                  opacity: 1,
                  scale: currentStep === index ? 1.02 : 1,
                  borderLeft: `4px solid ${layer.color}`
                }}
                transition={{ delay: (7-layer.id) * 0.05 }}
              >
                <div className="layer-header">
                  <span className="layer-icon" style={{ color: layer.color }}>{layer.icon}</span>
                  <div className="layer-text">
                    <span className="layer-id" style={{ borderColor: layer.color, color: layer.color }}>{layer.name}</span>
                    <span className="layer-title">{layer.fullName}</span>
                  </div>
                </div>
                
                {currentStep === index && (
                  <motion.div 
                    className="packet-indicator"
                    layoutId="packet"
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    style={{ backgroundColor: layer.color }}
                  >
                    <Send size={14} color="#fff" />
                  </motion.div>
                )}

                {currentStep > index && isDescending && (
                  <div className="layer-status-check">✓</div>
                )}
              </motion.div>
            ))}
            </AnimatePresence>
          </div>
        </section>
      </main>
    </div>
  );
};

export default App;
