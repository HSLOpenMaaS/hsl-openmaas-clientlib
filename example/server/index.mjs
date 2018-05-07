import express from 'express'
import axios from 'axios'
import dotenv from 'dotenv'
dotenv.load()

// Add your organization's HSL MaaS API Key as an X-API-Key header
axios.defaults.headers.common['X-API-Key'] = process.env.hslMaasApiKey

const app = express()
app.use(express.json())

app.post('/order', async (req, res) => {
  try {
    /** 
     * SUGGESTION:
     * Call your payment service to receive payment for the ticket.
     * You can price a ticket by it's selected attributes in the request body or
     * have a fixed price like in the example.
     */
    // await axios.post(process.env.paymentUrl, {price: 500, userId: req.body.clientId})

    // Order the ticket from HSL API
    const response = await axios.post(process.env.orderTicketUrl, req.body)

    res.status(response.status).json(response.data)
  } catch (e) {
    // Add proper error handling here
    let errCode = 500

    if (e.response) {
      errCode = e.response.status
    }

    res.sendStatus(errCode)
  }
})

// Server will run in port 3000
app.listen(3000)

console.log('Server started. Default location: http://localhost:3000')
