import axios from 'axios';

class NFTLego {
  async createPool({ contractid, tokenid }) {
    try {
      const sellOrdersResponse = await this.getSellOrdersByItem({
        contractid,
        tokenid,
      });
      const sellOrder =
        sellOrdersResponse.data && sellOrdersResponse.data.orders.length
          ? sellOrdersResponse.data.orders[0]
          : null;
      if (sellOrder) {
        const preparedOrder = this.getPreparedOrderFrom({ sellOrder });
        const preparedTransaction = await this.prepareTX(preparedOrder);
        // TODO: send preparedTransaction to smart contract
      }

      const preparedOrder = this.prepareTX(preparedOrder);
    } catch (error) {
      console.error(error);
    }
  }

  async getSellOrdersByItem({ contractid, tokenid }) {
    try {
      const response = await axios.get(
        `https://api-staging.rarible.com/protocol/v0.1/ethereum/order/orders/sell/byItem?contract=${contractid}&tokenId=${tokenid}`
      );

      console.log(`NFTLego > getSellOrdersByItem > response=${response}`);
      return response;
    } catch (error) {
      console.error(`NFTLego > getSellOrdersByItem > Error:\n${error.message}`);
    }
  }

  getPreparedOrderFrom(sellOrder) {
    console.log('SELL_ORDER: ', sellOrder);
    if (sellOrder && sellOrder.data) {
      const order = {
        amount: 1,
        payouts: sellOrder.data.payouts,
        originFees: sellOrder.data.originFees,
        hash: sellOrder.hash,
      };
      console.log(`NFTLego > getPreparedOrderFrom > order=${order}`);
      return order;
    } else {
      console.error(
        new Error(
          "getPreparedOrderFrom > couldn't prepare sellOrder for transaction"
        )
      );
    }
  }

  async prepareTX(order) {
    try {
      const txOrder = JSON.stringify(order);
      console.log(`NFTLego > prepareTX > txOrder=${txOrder}`);
      const response = await axios.post(
        `https://api-staging.rarible.com/protocol/v0.1/ethereum/order/orders/${order.hash}/prepareTx`,
        txOrder,
        {
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );
      console.log(`NFTLego > prepareTX > response=${response}`);
      return response;
    } catch (error) {
      console.error(`NFTLego > prepareTX > error=${error}`);
    }
  }
}

export default NFTLego;
