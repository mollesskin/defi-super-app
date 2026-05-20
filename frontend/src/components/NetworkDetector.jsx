import { useWalletContext } from '../context/WalletContext';

const ALLOWED_CHAINS = {
  421614: 'Arbitrum Sepolia',
  11155420: 'Optimism Sepolia',
  84532: 'Base Sepolia',
};

export default function NetworkDetector() {
  const { isConnected, chainId } = useWalletContext();

  if (!isConnected || !chainId) {
    return null;
  }

  const isCorrectNetwork = ALLOWED_CHAINS[chainId];

  if (!isCorrectNetwork) {
    return (
      <div className="bg-yellow-500 text-black p-4 rounded mb-6 flex justify-between items-center">
        <span className="font-semibold">Warning: You are on an unsupported network (Chain ID: {chainId})</span>
        <span className="text-sm">Switch to Arbitrum Sepolia</span>
      </div>
    );
  }

  return (
    <div className="bg-green-600 text-white p-4 rounded mb-6 font-semibold">
      Connected to {ALLOWED_CHAINS[chainId]}
    </div>
  );
}
