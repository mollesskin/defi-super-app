import { useWalletContext } from '../context/WalletContext';

export default function Dashboard() {
  const { account, isConnected, balance, chainId } = useWalletContext();

  const CHAIN_NAMES = {
    421614: 'Arbitrum Sepolia',
    11155420: 'Optimism Sepolia',
    84532: 'Base Sepolia',
  };

  if (!isConnected) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen gap-4">
        <h1 className="text-4xl font-bold">Welcome to DeFi Super-App</h1>
        <p className="text-xl text-gray-400">Connect your wallet to get started</p>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto">
      <h1 className="text-3xl font-bold mb-8">Dashboard</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
        <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
          <h2 className="text-lg font-semibold mb-4 text-gray-300">Wallet Balance</h2>
          <p className="text-3xl font-bold">{balance || '0'} ETH</p>
        </div>

        <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
          <h2 className="text-lg font-semibold mb-4 text-gray-300">Network</h2>
          <p className="text-sm font-semibold">{CHAIN_NAMES[chainId] || `Chain ID: ${chainId}`}</p>
        </div>

        <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
          <h2 className="text-lg font-semibold mb-4 text-gray-300">Status</h2>
          <p className="text-sm font-semibold text-green-400">Connected ✓</p>
        </div>
      </div>

      <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
        <h2 className="text-lg font-semibold mb-4">Your Address</h2>
        <p className="text-sm break-all font-mono text-gray-400 bg-gray-900 p-4 rounded">
          {account}
        </p>
      </div>
    </div>
  );
}
