import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import { WalletProvider } from './context/WalletContext';
import Dashboard from './pages/Dashboard';
import Swap from './pages/Swap';
import Lending from './pages/Lending';
import Governance from './pages/Governance';
import WalletConnect from './components/WalletConnect';
import './index.css';

export default function App() {
  return (
    <WalletProvider>
      <Router>
        <nav className="bg-gray-800 border-b border-gray-700 p-4">
          <div className="max-w-7xl mx-auto flex justify-between items-center">
            <div className="flex gap-8 items-center">
              <Link to="/" className="text-2xl font-bold hover:text-gray-300">
                DeFi 💰
              </Link>
              <div className="flex gap-6">
                <Link to="/" className="hover:text-gray-300 transition">Dashboard</Link>
                <Link to="/swap" className="hover:text-gray-300 transition">Swap</Link>
                <Link to="/lending" className="hover:text-gray-300 transition">Lending</Link>
                <Link to="/governance" className="hover:text-gray-300 transition">Governance</Link>
              </div>
            </div>
            <WalletConnect />
          </div>
        </nav>

        <main className="min-h-screen bg-gray-900 text-white p-8">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/swap" element={<Swap />} />
            <Route path="/lending" element={<Lending />} />
            <Route path="/governance" element={<Governance />} />
          </Routes>
        </main>
      </Router>
    </WalletProvider>
  );
}
