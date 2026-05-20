import { useWalletContext } from '../context/WalletContext';

export default function WalletConnect() {
  const { account, isConnected, connectWallet, disconnectWallet } = useWalletContext();

  if (isConnected) {
    return (
      <div className="flex gap-2 items-center">
        <span className="text-sm font-mono bg-gray-700 px-3 py-2 rounded">
          {account?.substring(0, 6)}...{account?.substring(-4)}
        </span>
        <button
          onClick={disconnectWallet}
          className="bg-red-600 hover:bg-red-700 px-4 py-2 rounded font-bold transition"
        >
          Disconnect
        </button>
      </div>
    );
  }

  return (
    <button
      onClick={connectWallet}
      className="bg-blue-600 hover:bg-blue-700 px-4 py-2 rounded font-bold transition"
    >
      Connect Wallet
    </button>
  );
}
