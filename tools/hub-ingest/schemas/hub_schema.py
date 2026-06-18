from pydantic import BaseModel, Field
from typing import List, Optional

class HubExtracted(BaseModel):
    """Strict schema for LLM extraction output."""
    name: str = Field(..., description="Official name of the coworking space or hub")
    description: Optional[str] = None
    address: Optional[str] = None
    neighborhood: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    price_hourly: Optional[float] = None
    price_daily: Optional[float] = None
    price_monthly: Optional[float] = None

    phone: Optional[str] = None
    whatsapp: Optional[str] = None
    email: Optional[str] = None
    website: Optional[str] = None

    amenities: List[str] = Field(default_factory=list, description="List of amenity ids like wifi, parking, quiet, ac, etc.")

    rating: Optional[float] = None
    is_verified: bool = False

    source_url: Optional[str] = None
    external_id: Optional[str] = None